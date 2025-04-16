const router = require('express').Router();
const Team = require('../models/team');
const Project = require('../models/project');
const {Student} = require('../models/user');

router.post('/addTeam', async (req, res) => {
    const {teamName, teamMembers, studentsYear} = req.body;

    try{
        const team = new Team({
            teamName: teamName,
            teamMembers: teamMembers,
            studentsYear: studentsYear
        });
        const savedTeam = await team.save();

        for(let i = 0; i < teamMembers.length; i++){
            const student = await Student.findOne({studentRollNo: teamMembers[i]});
            if(!student){
                return res.status(404).send("Student not found");
            }
            student.teamId = savedTeam._id;
            student.inAteam = true;
            await student.save();
        }

        res.status(200).send(savedTeam);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getTeam/:teamId', async (req, res) => {
    try{
        const team = await Team.find({_id: req.params.teamId});

        if(!team){
            return res.status(404).send("Team not found");
        }
        res.status(200).send(team);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getTeams/:studentsYear', async (req, res) => {
    try{
        const teams = await Team.find({studentsYear: req.params.studentsYear});

        if(!teams){
            return res.status(404).send("Teams not found");
        }

        res.status(200).send(teams);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.put('/assignProject', async (req, res) => {
    const {teamId, projectId} = req.body;
    try{
        const team = await Team.findOneAndUpdate({_id: teamId}, {$set: {projectId: projectId}}, {new: true});

        if(!team){
            return res.status(404).send("Team not found");
        }

        const project = await Project.findOneAndUpdate({_id: projectId}, {$set: {teamId: teamId}}, {new: true});

        if(!project){
            return res.status(404).send("Project not found");
        }

        for(let i = 0; i < team.teamMembers.length; i++){
            const user = await Student.findOne({studentRollNo: team.teamMembers[i]});
            if(!user){
                return res.status(404).send("User not found");
            }
            user.teamId = teamId;
            user.projectIds.push(projectId);
            user.inAteam = !user.inAteam;
            await user.save();
        }
        res.status(200).send(team);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getUnassignedTeams/:studentsYear', async (req, res) => {
    try{
        const teams = await Team.find({studentsYear: req.params.studentsYear, projectId: null});
        if(!teams){
            return res.status(404).send("Teams not found");
        }
        res.status(200).send(teams);
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getStudentDetails/:studentRollNo/:teamId', async (req, res) => {
    try{
        console.log(req.params.studentRollNo, req.params.teamId);
        const user = await Student.findOne({studentRollNo: req.params.studentRollNo, teamId: req.params.teamId});

        if(!user){
            return res.status(404).send("User not found");
        }
        res.status(200).send({studentName: user.studentName, studentYear: user.studentYear, studentBranch: user.studentBranch, studentSection: user.studentSection,studentSemester: user.studentSemester});
    }
    catch(err){
        res.status(500).send(err);
    }
});

router.get('/getNotInATeamStudents/:studentYear', async (req, res) => {
    try{
        const students = await Student.find({studentYear: req.params.studentYear, inAteam: false}).select('studentName studentRollNo')
        if(!students){
            return res.status(404).send("Students not found");
        }
        res.status(200).send(students);
    }
    catch(err){
        res.status(500).send(err);
    }
}
);

module.exports = router;