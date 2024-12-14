const router = require('express').Router();
const { BaseUser, Student} = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

router.post('/addUser', async (req, res) => {
    // if(req.user.role !== "admin"){
    //     return res.status(400).send("You are not authorized to add a user");
    // }
    try {
        const emailExists = await BaseUser.findOne({
            email: req.body.email
        });
        if (emailExists) {
            return res.status(400).send("Email already exists");
        }
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = new Student({
            username: req.body.username,
            email: req.body.email,
            password: hashedPassword,
            studentYear: req.body.studentYear,
            studentBranch: req.body.studentBranch,
            studentSection: req.body.studentSection,
            studentRollNo: req.body.studentRollNo,
            studentSemester: req.body.studentSemester
        });
        const savedUser = await user.save();
        res.status(200).send(savedUser);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        let user = await BaseUser.findOne({ email });
        if (!user) {
            return res.status(400).send("Invalid Email");
        }
        const role = user.role;

        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(400).send("Invalid Password");
        }
        const token = jwt.sign({ _id: user._id, role: role }, "varunkey");
        if (role === "Student") {
            res.status(200).send({ token: token, role: role, studentName: user.username, studentYear: user.studentYear, studentBranch: user.studentBranch, studentSection: user.studentSection, studentRollNo: user.studentRollNo, studentSemester: user.studentSemester, inAteam: user.inAteam, teamId: user.teamId, projectIds: user.projectIds });
        }
        else {
            res.status(200).send({ token: token, role: role });
        }
    } catch (err) {
        res.status(400).send(err);
    }
});

router.post('/changePassword', async (req, res) => {
    try {
        const user = await BaseUser.findOne({
            email: req.body.email
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        user.password = req.body.password;
        const savedUser = await user.save();
        res.status(200).send(savedUser);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.get('/getUser', async (req, res) => {
    if (req.user.role !== "admin") {
        return res.status(400).send("You are not authorized to view a user");
    }
    try {
        const user = await BaseUser.findOne({
            email: req.body.email
        });
        if (!user) {
            return res.status(400).send("User not found");
        }
        res.status(200).send(user);
    } catch (err) {
        res.status(400).send(err);
    }
});

// * To be removed later

router.post('/addAdmin', async (req, res) => {
    try {
        const emailExists = await BaseUser.findOne({
            email: req.body.email
        });
        if (emailExists) {
            return res.status(400).send("Email already exists");
        }
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const admin = new Admin({
            username: req.body.username,
            email: req.body.email,
            password: hashedPassword
        });
        const savedAdmin = await admin.save();
        res.status(200).send(savedAdmin);
    } catch (err) {
        res.status(400).send(err);
    }
});

module.exports = router;