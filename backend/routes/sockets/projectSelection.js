const Project = require('../../models/project');
const Team = require('../../models/team');
const mongoose = require('mongoose');

const SESSION_TIMEOUT = 15 * 60 * 1000; 
const ProjectSelection = (io) => {

    let activeSession = null;
    const connectedTeams = new Map();
    io.on("connection", (socket)=>{
        console.log(`User connected for Project Selection: ${socket.id}`);
        
        socket.on("admin_start_selection", async ({targetYear}) => {
            const session = await mongoose.startSession();
            session.startTransaction();
            try{
                const projects = await Project.find({year: targetYear, isReleased: false, isAssigned: false}).session(session);
                if(projects.length === 0){
                    session.abortTransaction();
                    socket.emit("release_error", {
                        code : "NO_PROJECTS",
                        message: "No projects available for selection"
                    });
                    return;
                }
                activeSession = {
                    targetYear,
                    projects : projects.map(p => p._id),
                    allocations : new Map(),
                    selectedTeams : new Set(),
                    timeout : setTimeout(() => {
                        endSession();
                    }, SESSION_TIMEOUT)
                }

                await Project.updateMany(
                    {_id: {$in: projects.map(p => p._id)}},
                    {$set: {isReleased: true}},
                    {session}
                );

                await session.commitTransaction();
                
                io.emit("projects_released", {
                    targetYear,
                    duration: SESSION_TIMEOUT,
                    projects : projects.map(p => ({
                        id: p._id,
                        name: p.projectTitle,
                        description: p.projectDescription,
                    }))
                });
            }
            catch(err){
                session.abortTransaction();
                console.error('Error starting selection:', err);
                socket.emit("release_error", {code : "ERROR_STARTING_SELECTION" ,message: err.message});
                return;
            }
            finally{
                session.endSession();
            }
        });

        const endSession = async()=>{
            if(!activeSession){
                return;
            }
            const session = await mongoose.startSession();
            session.startTransaction();

            try{
                await Project.updateMany(
                    {_id: {$in: activeSession.projects}},
                    {$set: {isReleased: false}},
                    {session}
                );

                await session.commitTransaction();
                io.emit("projects_selection_ended", {
                    code : "SESSION_ENDED",
                    message: "Selection session ended",
                    targetYear: activeSession.targetYear
                });
            }
            catch(err){
                await session.abortTransaction();
                console.error('Error ending selection session:', err);
                io.emit("release_error", {
                    code : "ERROR_ENDING_SESSION",
                    message: err.message});
                return; 
            }
            finally{
                clearTimeout(activeSession.timeout);    
                activeSession = null;
                connectedTeams.clear();
                session.endSession();
            }
        }  

        socket.on("admin_stop_selection",endSession);

        socket.on("team_select_project", async ({teamId, projectId}) => {
            if(connectedTeams.has(teamId)){
                socket.emit("selection_error", {
                    code : "TEAM_ALREADY_CONNECTED",
                    message: "Your team is already connected from another device"});
                return;
            }
            connectedTeams.set(teamId, socket.id);
            const session = await mongoose.startSession();
            session.startTransaction();
            try{
                if(!activeSession){
                    session.abortTransaction();
                    socket.emit("release_error", {
                        code : "NO_ACTIVE_SESSION",
                        message: "No selection session active"});
                    return;
                }

                const [team, project] = await Promise.all([ 
                    Team.findById(teamId),
                    Project.findById(projectId)
                ])

                if(!team || !project){
                    session.abortTransaction();
                    socket.emit("selection_error", {
                        code : "INVALID_TEAM_OR_PROJECT",
                        message: "Invalid team or project ID"});
                    return;
                }

                if(team.studentsYear !== activeSession.targetYear){
                    session.abortTransaction();
                    socket.emit("selection_error", {
                        code : "INVALID_TEAM_YEAR",
                        message: "Team year does not match selection year"});
                    return;
                }

                if(activeSession.allocations.has(projectId)){
                    session.abortTransaction();
                    socket.emit("selection_error", {
                        code : "PROJECT_ALREADY_SELECTED",
                        message: "Project already selected by another team"});
                    return;
                }
                if(activeSession.selectedTeams.has(teamId)){
                    session.abortTransaction();
                    socket.emit("selection_error", {
                        code : "TEAM_ALREADY_SELECTED",
                        message: "Team already selected a project"});
                    return;
                }   

                const updatedProject = await Project.findOneAndUpdate(
                    {_id: projectId, isReleased: true, isAssigned: false},
                    {$set: {isAssigned: true, teamId: teamId}},
                    {new: true, session}
                );

                if(!updatedProject){
                    session.abortTransaction();
                    socket.emit("selection_error", {
                        code : "PROJECT_NOT_AVAILABLE",
                        message: "Project not available for selection"});
                    return;
                }

                activeSession.allocations.set(projectId, teamId);
                activeSession.selectedTeams.add(teamId);

                await Team.findByIdAndUpdate(
                    teamId,
                    {$set: {projectId: projectId, hasSelected: true}},
                    {session}
                );

                await session.commitTransaction();

                socket.emit("project_selected", {
                    projectId,
                    projectName: updatedProject.projectTitle,
                    projectDescription: updatedProject.projectDescription
                });
            }
            catch(err){
                await session.abortTransaction();
                if(connectedTeams.has(teamId)){
                    connectedTeams.delete(teamId);
                }
                console.error('Error selecting project:', err);
                socket.emit("selection_error", {
                    code : "ERROR_SELECTING_PROJECT",
                    message: err.message});
                return;
            }
            finally{
                session.endSession();
            }
        });
    })
}

module.exports = {ProjectSelection};