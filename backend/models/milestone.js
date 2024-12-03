const mongoose = require('mongoose');

const MilestoneSchema = new mongoose.Schema({
    milestoneName: {
        type: String,
        required: true,
        min: 3,
        max: 50,
        unique: true
    },
    milestoneDescription: {
        type: String,
        required: true
    },
    milestoneStatus: {
        type: Boolean,
        default: false
    },
    milestoneStartDate: {
        type: Date,
        required: true
    },
    milestoneEndDate: {
        type: Date,
        required: true
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

module.exports = mongoose.model('Milestone', MilestoneSchema);