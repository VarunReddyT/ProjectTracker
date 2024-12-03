const mongoose = require('mongoose');

const DailyTaskSchema = new mongoose.Schema({
    dailyTask:{
        type: String,
        required: true
    },
    taskAddedDate: {
        type: Date,
        required: true
    },
    taskStatus: {
        type: Boolean,
        default : false
    },
    deadline: {
        type: Date,
        required: true
    },
    deadlineStatus: {
        type: Boolean,
        default : false
    },
    projectId: {
        type: mongoose.Schema.Types.ObjectId,
        ref : 'Project',
        required: true
    },
    studentId : {
        type: mongoose.Schema.Types.ObjectId,
        ref : 'User',
        required: true
    }
});

module.exports = mongoose.model('DailyTask', DailyTaskSchema);