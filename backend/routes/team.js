const router = require('express').Router();
const Team = require('../models/team');

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
        res.status(400).send(err);
    }
});

router.get('/getTeam/:teamId', async (req, res) => {
    try{
        const team = await Team.find({_id: req.params.teamId});
        res.status(200).send(team);
    }
    catch(err){
        res.status(400).send(err);
    }
});

router.put('/assignProject', async (req, res) => {
    const {teamId, projectId} = req.body;
    try{
        const team = await Team.findOneAndUpdate({_id: teamId}, {projectId: projectId});
        res.status(200).send(team);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;