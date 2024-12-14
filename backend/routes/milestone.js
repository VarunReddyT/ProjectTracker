const router = require('express').Router();
const Milestone = require('../models/milestone');

router.post('/addMilestone', async (req, res) => {
    const {milestoneName, milestoneDescription, milestoneStartDate, milestoneEndDate, projectId} = req.body;
    try{
        const milestone = new Milestone({
            milestoneName: milestoneName,
            milestoneDescription: milestoneDescription,
            milestoneStartDate: milestoneStartDate,
            milestoneEndDate: milestoneEndDate,
            projectId: projectId
        });
        const savedMilestone = await milestone.save();
        res.status(200).send(savedMilestone);
    }
    catch(err){
        res.status(400).send(err);
    }
});

router.get('/getMilestone/:projectId', async (req, res) => {
    const projectId = req.params.projectId;
    let studentMilestone = [];
    try{
        const milestone = await Milestone.find({projectId: projectId});
        for(let i=0; i<milestone.length; i++){
           studentMilestone.push({
                milestoneName: milestone[i].milestoneName,
                milestoneDescription: milestone[i].milestoneDescription,
                milestoneStartDate: milestone[i].milestoneStartDate,
                milestoneEndDate: milestone[i].milestoneEndDate,
                studentDetails: milestone[i].studentDetails
              });
        }
        res.status(200).send(studentMilestone);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.post('/submitMilestone', async (req, res) => {
    const {milestoneId, projectId, studentRollNo, mileStoneUrl} = req.body;
    try{
        const milestone = await Milestone.findOne({ _id : milestoneId, projectId: projectId});
        if(!milestone){
            res.status(400).send("Milestone not found");
        }
        if(milestone.endDate < Date.now()){
            res.status(400).send("Milestone submission date is over");
        }
        for(let i=0; i<milestone.studentDetails.length; i++){
            if(milestone.studentDetails[i].studentRollNo === studentRollNo){
                milestone.studentDetails[i].mileStoneUrl = mileStoneUrl;
                milestone.studentDetails[i].mileStoneStatus = true;
                break;
            }
        }
        const savedMilestone = await milestone.save();
        res.status(200).send(savedMilestone);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;