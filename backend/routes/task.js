const router = require('express').Router();
const Task = require('../models/task');

router.post('/addTask', async (req, res) => {
    const {taskName, taskDescription, projectId, studentId} = req.body;

    try{
        const task = new Task({
            taskName: taskName,
            taskDescription: taskDescription,
            projectId: projectId,
            studentId: studentId
        });
        const savedTask = await task.save();
        res.status(200).send(savedTask);
    }
    catch(err){
        res.status(400).send(err);
    }
});

router.get('/getTasks/:studentId/:projectId', async (req, res) => {
    const studentId = req.params.studentId;
    const projectId = req.params.projectId;

    try{
        const tasks = await Task.find({studentId: studentId, projectId: projectId});
        res.status(200).send(tasks);
    }
    catch(err){
        res.status(500).send(err);
    }   
});

router.put('/updateTask/:taskId', async (req, res) => {
    const taskId = req.params.taskId;
    const {taskName, taskDescription, taskStatus} = req.body;

    try{
        const task = await Task.findById(taskId);
        task.taskName = taskName;
        task.taskDescription = taskDescription;
        task.taskStatus = taskStatus;
        const updatedTask = await task.save();
        res.status(200).send(updatedTask);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.delete('/deleteTask/:taskId', async (req, res) => {
    const taskId = req.params.taskId;

    try{
        const task = await Task.findById(taskId);
        const deletedTask = await task.remove();
        res.status(200).send(deletedTask);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;