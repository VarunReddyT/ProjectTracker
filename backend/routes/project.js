const router = require('express').Router();
const Project = require('../models/project');
const Team = require('../models/team');
const {BaseUser,Student} = require('../models/user');

router.post('/addProject', async (req, res) => {
    // if(req.user.role !== "admin"){
    //     return res.status(400).send("You are not authorized to assign a project");
    // }
    try {
        const project = new Project({
            projectTitle : req.body.projectTitle,
            projectType: 'Academic',
            projectDescription: req.body.projectDescription,
            projectDomain: req.body.projectDomain
        });
        const savedProject = await project.save();

        res.status(200).send(savedProject);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post('/addPersonalProject/:studentRollNo',async(req,res)=>{
    try{
        const project = new Project({
            projectTitle : req.body.projectTitle,
            projectType: 'Personal',
            projectDescription: req.body.projectDescription,
            projectDomain: req.body.projectDomain,
            studentRollNo : req.params.studentRollNo,
            projectStatus : 'Ongoing',
        })
        const savedProject = await project.save();
        const user = await BaseUser.findOne({studentRollNo : req.params.studentRollNo});
        if (!user) {
            return res.status(404).send({ message: "User not found" });
        }
        user.projectIds.push(savedProject._id);
        await user.save();
        res.status(200).send(savedProject);
    }
    catch(err){
        res.status(500).send(err);
    }
})

router.post('/assignProject/:teamId', async (req, res) => {
    // if(req.user.role !== "admin"){
    //     return res.status(400).send("You are not authorized to assign a project");
    // }
    try {
        const project = await Project.findOne({
            _id: req.body.projectId
        });
        if (!project) {
            return res.status(400).send("Project not found");
        }
        project.teamId = req.params.teamId;
        project.projectStatus = 'Ongoing';
        project.projectStartDate = new Date();
        const savedProject = await project.save();

        const team = await Team.findOne({
            _id: req.params.teamId
        });

        if (!team) {
            return res.status(400).send("Team not found");
        }
        team.projectId = req.body.projectId;
        const savedTeam = await team.save();

        for (let i = 0; i < team.teamMembers.length; i++) {
            const user = await BaseUser.findOne({
                studentRollNo: team.teamMembers[i]
            });
            if (!user) {
                return res.status(400).send("User not found");
            }
            user.projectIds.push(req.body.projectId);
            await user.save();
        }
        res.status(200).send({savedProject,savedTeam});
    } catch (err) {
        res.status(400).send(err);
    }
}
);

router.get('/getProject/:projectId', async (req, res) => {
    try {
        const project = await Project.findOne({
            _id: req.params.projectId
        });
        if (!project) {
            return res.status(400).send("Project not found");
        }
        res.status(200).send(project);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getProjects/:studentRollNo', async (req, res) => {
    try {
        const user = await BaseUser.findOne({
            studentRollNo: req.params.studentRollNo
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        const projects = await Project.find({
            _id: { $in: user.projectIds }
        });
        if(!projects){
            res.status(200).send({message : "No current projects"})
        }
        res.status(200).send(projects);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getOngoingProjects/:studentRollNo', async (req, res) => {
    try {
        const user = await Student.findOne({
            studentRollNo: req.params.studentRollNo
        });
        if (!user) {
            return res.status(400).json({ 
                success: false, 
                message: "User not found" 
            });
        }
        const projects = await Project.find({
            _id: { $in: user.projectIds },
            projectStatus: 'Ongoing',
            $or: [
                { studentRollNo: req.params.studentRollNo },
                { studentRollNo: null }
            ]
        });

        const studentProjects = [];
        for (let i = 0; i < projects.length; i++) {
            if (projects[i].teamId) {
                const team = await Team.findOne({
                    _id: projects[i].teamId
                });
                if (!team) {
                    return res.status(400).json({ 
                        success: false, 
                        message: "Team not found" 
                    });
                }
                
                if (team.teamMembers.includes(req.params.studentRollNo)) {
                    studentProjects.push(projects[i]);
                }
            }
            else if(projects[i].studentRollNo === req.params.studentRollNo){
                studentProjects.push(projects[i]);
            }
        }     
        res.status(200).send(studentProjects);   
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getCompletedProjects/:studentRollNo', async (req, res) => {
    try {
        const user = await BaseUser.findOne({
            studentRollNo: req.params.studentRollNo
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        const projects = await Project.find({
            _id: { $in: user.projectIds },
            projectStatus: 'Completed'
        });
        res.status(200).send(projects);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getUnassignedProjects', async (req, res) => {
    try {
        const projects = await Project.find({
            projectStatus: 'Unassigned',
            studentRollNo : null
        });
        res.status(200).send(projects);
    } catch (err) {
        res.status(400).send(err);
    }
}
);

router.get('/getTeamProjects/:teamId', async (req, res) => {
    try {
        const team = await Team.findOne({
            _id: req.params.teamId
        });
        if (!team) {
            return res.status(400).send("Team not found");
        }
        const project = await Project.findOne({
            _id: team.projectId
        });
        if (!project) {
            return res.status(400).send("Project not found");
        }
        res.status(200).send(project);
    } catch (err) {
        res.status(400).send(err);
    }
});


module.exports = router;