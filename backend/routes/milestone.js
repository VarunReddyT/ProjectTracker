const router = require('express').Router();
const Milestone = require('../models/milestone');
const Project = require('../models/project');

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
    let projectMilestones = [];
    try{
        const milestone = await Milestone.find({projectId: projectId});
        for(let i=0; i<milestone.length; i++){
           projectMilestones.push({
                milestoneName: milestone[i].milestoneName,
                milestoneDescription: milestone[i].milestoneDescription,
                milestoneStartDate: milestone[i].milestoneStartDate,
                milestoneEndDate: milestone[i].milestoneEndDate,
              });
        }
        res.status(200).send(projectMilestones);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.post('/submitMilestone', async (req, res) => {
    const {milestoneId, projectId, studentRollNo, mileStoneUrl} = req.body;
    try{
        const project = await Project.findById(projectId);
        if(project.projectStatus === 'Unassigned'){
            res.status(400).send('Project is Unassigned');
        }
        for(let i=0; i<project.milestones.length; i++){
            if(project.milestones[i].milestoneId == milestoneId){
                project.milestones[i].studentDetails.push({
                    studentRollNo: studentRollNo,
                    mileStoneUrl: mileStoneUrl,
                    mileStoneStatus: true
                });
            }
        }
        const savedProject = await project.save();
        res.status(200).send(savedProject);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;