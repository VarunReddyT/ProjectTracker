const router = require('express').Router();
const Task = require('../models/task');

router.post('/addTask', async (req, res) => {
    const {taskName, taskDescription, projectId, studentRollNo} = req.body;

    try{
        const task = new Task({
            taskName: taskName,
            taskDescription: taskDescription,
            projectId: projectId,
            studentRollNo: studentRollNo
        });
        const savedTask = await task.save();
        res.status(200).send(savedTask);
    }
    catch(err){
        res.status(400).send(err);
    }
});

router.get('/getTasks/:studentRollNo/:projectId', async (req, res) => {
    const studentRollNo = req.params.studentRollNo;
    const projectId = req.params.projectId;

    try{
        const tasks = await Task.find({studentRollNo: studentRollNo, projectId: projectId});
        res.status(200).send(tasks);
    }
    catch(err){
        res.status(500).send(err);
    }   
});

router.put('/updateTask/:taskId', async (req, res) => {
    const taskId = req.params.taskId;
    const {taskName, taskDescription} = req.body;

    try{
        const task = await Task.findById(taskId);
        task.taskName = taskName;
        task.taskDescription = taskDescription;
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

router.get('/getTaskStatuses/:studentRollNo/:projectId', async (req, res) => {
    const studentRollNo = req.params.studentRollNo;
    const projectId = req.params.projectId;

    try{
        const tasks = await Task.find({studentRollNo: studentRollNo, projectId: projectId});
        const taskStatuses = tasks.map(task => task.taskStatus);
        const ongoing = taskStatuses.filter(status => status === false).length;
        const completed = taskStatuses.filter(status => status === true).length;
        res.status(200).send({ongoing: ongoing, completed: completed});
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.put('/updateTaskStatus/:taskId', async (req, res) => {
    const taskId = req.params.taskId;

    try{
        const task = await Task.findById(taskId);
        task.taskStatus = !task.taskStatus;
        const updatedTask = await task.save();
        res.status(200).send(updatedTask);
    }
    catch(err){
        res.status(500).send(err);
    }
});

module.exports = router;