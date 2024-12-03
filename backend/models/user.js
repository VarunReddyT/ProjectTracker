const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        min: 3,
        max: 20,
        unique: true
    },
    email: {
        type: String,
        required: true,
        max: 50,
        unique: true
    },
    password: {
        type: String,
        required: true,
        min: 6
    },
    projectIds : {
        type: [mongoose.Schema.Types.ObjectId],
        ref : 'Project',
        default: []
    },
    inAteam: {
        type: Boolean,
        default: false
    },
    teamId: {
        type: mongoose.Schema.Types.ObjectId,
        ref : 'Team',
        default: null
    },
    studentYear : {
        type: Number,
        default: null
    },
    studentBranch : {
        type: String,
        default: null
    },
    studentSection : {
        type: String,
        default: null
    },
    studentRollNo : {
        type: String,
        default: null
    },
    studentSemester : {
        type: Number,
        default: null
    }
});

module.exports = mongoose.model('User', UserSchema);