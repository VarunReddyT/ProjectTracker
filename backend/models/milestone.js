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
    },
    studentDetails :[{
        studentRollNo : {
            type : String
        },
        mileStoneUrl : {
            type : String,
            default : null
        },
        mileStoneStatus : {
            type : Boolean,
            default : false
        }

    }]
});

module.exports = mongoose.model('Milestone', MilestoneSchema);