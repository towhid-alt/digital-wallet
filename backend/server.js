const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const http = require("http")
const { Server } = require("socket.io")

dotenv.config();
const app = express();
const server = http.createServer(app)
//Socket.IO setup
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for now
        // Allows connections from ANY website/domain
        methods: ["GET", "POST"]//Only allow GET and POST requests
    }
});

//TODO: Setup socket connections

const PORT = process.env.PORT || 5002;
app.use(express.json());
app.use(cookieParser());
app.use(cors())

const authRouter = require('./src/routes/authroutes.js')
const accountsRouter = require('./src/routes/accountRoutes.js')
const requestsRouter = require('./src/routes/friendRequests.js')

app.use('/api/auth',authRouter)
app.use('/api/accounts',accountsRouter)
app.use('/api/requests', requestsRouter)

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
})

module.exports = app;