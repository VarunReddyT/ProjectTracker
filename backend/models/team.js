const mongoose = require('mongoose');

const TeamSchema = new mongoose.Schema({
    teamName: {
        type: String,
        required: true,
        min: 3,
        max: 50,
        unique: true
    },
    teamMembers: {
        type: [String],
        required: true
    },
    projectId: {
        type: mongoose.Schema.Types.ObjectId,
        ref : 'Project'
    },
    studentsYear: {
        type: Number, 
        required: true
    },
    hasSelected: {
        type: Boolean,
        default: false
    }
});

module.exports = mongoose.model('Team', TeamSchema);