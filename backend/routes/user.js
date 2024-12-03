const router = require('express').Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

router.post('/addUser', async (req, res) => {
    if(req.user.role !== "admin"){
        return res.status(400).send("You are not authorized to add a user");
    }
    try {
        const emailExists = await User.findOne({
            email: req.body.email
        });
        if (emailExists) {
            return res.status(400).send("Email already exists");
        }
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = new User({
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
    const {email, password} = req.body;
    try {
        const user = await User.findOne({email});
        if (!user) {
            return res.status(400).send("Invalid Credentials");
        }
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(400).send("Invalid Credentials");
        }
        const token = jwt.sign({_id: user._id, role: user.role}, "varunkey");
        res.status(200).send(token);
    } catch (err) {
        res.status(400).send(err);
    }
});

router.post('/changePassword', async (req, res) => {
    try {
        const user = await User.findOne({
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
    if(req.user.role !== "admin"){
        return res.status(400).send("You are not authorized to view a user");
    }
    try {
        const user = await User.findOne({
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

module.exports = router;