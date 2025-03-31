const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
    taskName: {
        type: String,
        required: true,
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
    studentRollNo: {
        type: String,
        required: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Task', TaskSchema);