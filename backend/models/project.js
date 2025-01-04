const mongoose = require('mongoose');
const milestone = require('./milestone');

const ProjectSchema = new mongoose.Schema({
    projectTitle: {
        type: String,
        required: true,
        min: 3,
        max: 50,
        unique: true
    },
    projectType: {
        type: String,
        required: true,
        enum: ['Academic', 'Personal']
    },
    projectDescription: {
        type: String,
        required: true
    },
    projectDomain: {
        type: String,
        required: true
    },
    projectTechnologies: {
        type: [String],
        required: true
    },
    projectStatus: {
        type: String,
        enum: ['Unassigned','Ongoing', 'Completed'],
        default: 'Unassigned'
    },
    projectStartDate: {
        type: Date
    },
    projectEndDate: {
        type: Date
    },
    teamId : {
        type: mongoose.Schema.Types.ObjectId,
        ref : 'Team'
    },
    studentRollNo : {
        type : String,
        default : null
    },
    teamYear : {
        type : Number,
        default : null
    },
    milestones : [{
        milestoneId : {
            type : mongoose.Schema.Types.ObjectId,
            ref : 'Milestone'
        },
        studentDetails : [{
            studentRollNo : {
                type : String,
                default : null
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
    }]
});

module.exports = mongoose.model('Project', ProjectSchema);