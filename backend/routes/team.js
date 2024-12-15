const router = require('express').Router();
const Team = require('../models/team');
const Project = require('../models/project');
const {Student} = require('../models/user');

router.post('/addTeam', async (req, res) => {
    const {teamName, teamMembers} = req.body;

    try{
        const team = new Team({
            teamName: teamName,
            teamMembers: teamMembers
        });
        const savedTeam = await team.save();
        res.status(200).send(savedTeam);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getTeam/:teamId', async (req, res) => {
    try{
        const team = await Team.find({_id: req.params.teamId});

        if(!team){
            return res.status(404).send("Team not found");
        }
        res.status(200).send(team);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getTeams/:studentsYear', async (req, res) => {
    try{
        const teams = await Team.find({studentsYear: req.params.studentsYear});

        if(!teams){
            return res.status(404).send("Teams not found");
        }

        res.status(200).send(teams);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.put('/assignProject', async (req, res) => {
    const {teamId, projectId} = req.body;
    try{
        const team = await Team.findOneAndUpdate({_id: teamId}, {$set: {projectId: projectId}}, {new: true});

        if(!team){
            return res.status(404).send("Team not found");
        }

        const project = await Project.findOneAndUpdate({_id: projectId}, {$set: {teamId: teamId}}, {new: true});

        if(!project){
            return res.status(404).send("Project not found");
        }

        for(let i = 0; i < team.teamMembers.length; i++){
            const user = await Student.findOne({studentRollNo: team.teamMembers[i]});
            if(!user){
                return res.status(404).send("User not found");
            }
            user.teamId = teamId;
            user.projectIds.push(projectId);
            user.inAteam = !user.inAteam;
            await user.save();
        }
        res.status(200).send(team);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;