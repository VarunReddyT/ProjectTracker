const router = require('express').Router();
const Project = require('../models/Project');
const Team = require('../models/team');
const User = require('../models/User');

router.post('/addProject', async (req, res) => {
    if(req.user.role !== "admin"){
        return res.status(400).send("You are not authorized to assign a project");
    }
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
        res.status(400).send(err);
    }
});

router.post('/assignProject/:teamId', async (req, res) => {
    if(req.user.role !== "admin"){
        return res.status(400).send("You are not authorized to assign a project");
    }
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

router.get('/getProjects/:userId', async (req, res) => {
    try {
        const user = await User.findOne({
            _id: req.params.userId
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        const projects = await Project.find({
            _id: { $in: user.projectIds }
        });
        res.status(200).send(projects);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getOngoingProjects/:userId', async (req, res) => {
    try {
        const user = await User.findOne({
            _id: req.params.userId
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        const projects = await Project.find({
            _id: { $in: user.projectIds },
            projectStatus: 'Ongoing'
        });
        res.status(200).send(projects);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getCompletedProjects/:userId', async (req, res) => {
    try {
        const user = await User.findOne({
            _id: req.params.userId
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

module.exports = router;