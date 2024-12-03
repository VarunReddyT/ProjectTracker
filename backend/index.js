const express = require('express');
const app = express();
const mongoose = require('mongoose');
const cors = require('cors');

const UserRoutes = require('./routes/user');
const TeamRoutes = require('./routes/team');
const ProjectRoutes = require('./routes/project');
const TaskRoutes = require('./routes/task');
// const MilestoneRoutes = require('./routes/milestone');

require('dotenv').config();
app.use(express.json());
app.use(cors());

mongoose.connect("mongodb+srv://Tvarun2014:varunreddy2014@cluster0.cc98p65.mongodb.net/projecttracker")
    .then(() => {
        console.log('Connected to MongoDB');
    })
    .catch(err => console.log(err));

app.get('/', (req, res) => {
    res.send('Hello World');
});

app.use('/api/user', UserRoutes);
app.use('/api/team', TeamRoutes);
app.use('/api/project', ProjectRoutes);
app.use('/api/task', TaskRoutes);
// app.use('/api/milestone', MilestoneRoutes);

app.listen(4000, () => {
    console.log(`Server is running on port 4000`);
});