const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
    taskName: {
        type: String,
        required: true,
        min: 3,
        max: 50,
        unique: true
    },
    taskDescription: {
        type: String,
        required: true
    },
    taskStatus: {
        type: Boolean,
        default: false
    },
    taskAddedDate: {
        type: Date,
        default: Date.now
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

module.exports = mongoose.model('Task', TaskSchema);