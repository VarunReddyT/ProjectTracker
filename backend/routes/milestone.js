const router = require('express').Router();
const Milestone = require('../models/milestone');

router.post('/addMilestone', async (req, res) => {
    const {milestoneName, milestoneDescription, projectId} = req.body;

    try{
        const milestone = new Milestone({
            milestoneName: milestoneName,
            milestoneDescription: milestoneDescription,
            projectId: projectId
        });
        const savedMilestone = await milestone.save();
        res.status(200).send(savedMilestone);
    }
    catch(err){
        res.status(400).send(err);
    }
});


module.exports = router;