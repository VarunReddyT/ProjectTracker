const Project = require('../../models/project');
const Team = require('../../models/team');
const {socketGuard, activateSelection, deactivateSelection} = require('../../middleware/socketSelection');
const mongoose = require('mongoose');

const SESSION_TIMEOUT = 15 * 60 * 1000; 
const ProjectSelection = (io) => {
    io.use(socketGuard);

    let activeSession = null;
    const connectedTeams = new Map();
    io.on("connection", (socket)=>{
        console.log(`User connected for Project Selection: ${socket.id}`);

        socket.on("admin_start_selection", async ({targetYear}) => {
            try{
                const session = await mongoose.startSession();
                const projects = await Project.find({year: targetYear, isReleased: false, isAssigned: false});
                if(projects.length === 0){
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
                    selectedTeams : new Set()
                }

                await Project.updateMany(
                    {_id: {$in: projects.map(p => p._id)}},
                    {$set: {isReleased: true}}
                );
                
                io.emit("projects_released", {
                    targetYear,
                    projects : projects.map(p => ({
                        id: p._id,
                        name: p.projectTitle,
                        description: p.projectDescription,
                    }))
                });
            }
            catch(err){
                console.error('Error fetching projects:', err);
                socket.emit("release_error", {code : "ERROR_FETCHING_PROJECTS" ,message: err.message});
                return;
            }
        });

        socket.on("admin_stop_selection", async () => {
            if(!activeSession){
                socket.emit("release_error", {
                    code : "NO_ACTIVE_SESSION",
                    message: "No active session to stop"});
                return;
            }
            try{
                await Project.updateMany(
                    {_id: {$in: activeSession.projects}},
                    {$set: {isReleased: false}}
                );
                activeSession = null;
                io.emit("projects_selection_stopped", {});
            }
            catch(err){
                console.error('Error stopping selection:', err);
                socket.emit("release_error", {
                    code : "ERROR_STOPPING_SELECTION",
                    message: err.message});
                return;
            }
        });

        socket.on("team_select_project", async ({teamId, projectId}) => {
            try{
                if(!activeSession){
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
                    socket.emit("selection_error", {
                        code : "INVALID_TEAM_OR_PROJECT",
                        message: "Invalid team or project ID"});
                    return;
                }

                if(team.studentsYear !== activeSession.targetYear){
                    socket.emit("selection_error", {
                        code : "INVALID_TEAM_YEAR",
                        message: "Team year does not match selection year"});
                    return;
                }

                if(activeSession.allocations.has(projectId)){
                    socket.emit("selection_error", {
                        code : "PROJECT_ALREADY_SELECTED",
                        message: "Project already selected by another team"});
                    return;
                }
                if(activeSession.selectedTeams.has(teamId)){
                    socket.emit("selection_error", {
                        code : "TEAM_ALREADY_SELECTED",
                        message: "Team already selected a project"});
                    return;
                }   

                const updatedProject = await Project.findOneAndUpdate(
                    {_id: projectId, isReleased: true, isAssigned: false},
                    {$set: {isAssigned: true, teamId: teamId}},
                    {new: true}
                );

                if(!updatedProject){
                    socket.emit("selection_error", {message: "Project not available for selection"});
                    return;
                }

                activeSession.allocations.set(projectId, teamId);
                activeSession.selectedTeams.add(teamId);

                await Team.findByIdAndUpdate(
                    teamId,
                    {$set: {projectId: projectId, hasSelected: true}},
                );

                socket.emit("project_selected", {
                    projectId,
                    projectName: updatedProject.projectTitle,
                    projectDescription: updatedProject.projectDescription
                });
            }
            catch(err){
                console.error('Error selecting project:', err);
                socket.emit("selection_error", {
                    code : "ERROR_SELECTING_PROJECT",
                    message: err.message});
                return;
            }
        });
    })
}

module.exports = {ProjectSelection};