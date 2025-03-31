const {initSocket} = require('./socket');
const express = require('express');
const app = express();
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const UserRoutes = require('./routes/user');
const TeamRoutes = require('./routes/team');
const ProjectRoutes = require('./routes/project');
const TaskRoutes = require('./routes/task');
const MilestoneRoutes = require('./routes/milestone');
const {SocketRoutes} = require('./routes/sockets/chat');
const {ProjectSelectionRoutes} = require('./routes/sockets/projectSelection');
require('dotenv').config();
app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGO_URI)
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
app.use('/api/milestone', MilestoneRoutes);

const server = http.createServer(app);
const io = initSocket(server);
app.options('*', cors());
SocketRoutes(io);
ProjectSelectionRoutes(io);

server.listen(4000, "0.0.0.0", () => {
    console.log(`Server is running on port 4000`);
});