const mongoose = require('mongoose');

const BaseUserSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      min: 3,
      max: 20,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      max: 50,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
  },
  {
    discriminatorKey: 'role',
    timestamps: true, 
  }
);

const BaseUser = mongoose.model('User', BaseUserSchema);

const StudentSchema = new mongoose.Schema({
  projectIds: {
    type: [mongoose.Schema.Types.ObjectId],
    ref: 'Project',
    default: [],
  },
  inAteam: {
    type: Boolean,
    default: false,
  },
  teamId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Team',
    default: null,
  },
  studentName:{
    type: String,
    default: null,
  },
  studentYear: {
    type: Number,
    default: null,
  },
  studentBranch: {
    type: String,
    default: null,
  },
  studentSection: {
    type: String,
    default: null,
  },
  studentRollNo: {
    type: String,
    default: null,
  },
  studentSemester: {
    type: Number,
    default: null,
  },
});

const AdminSchema = new mongoose.Schema({});

const MentorSchema = new mongoose.Schema({
  mentorName: {
    type: String,
    required: true,
  },
  assignedTeamsAndProjects : {
    type: Map,
    of: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Team',
    }],
    default: {},
  }
});

const Student = BaseUser.discriminator('Student', StudentSchema);
const Admin = BaseUser.discriminator('Admin', AdminSchema);
const Mentor = BaseUser.discriminator('Mentor', MentorSchema);

module.exports = { BaseUser, Student, Admin, Mentor };