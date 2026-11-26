const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const http = require("http")
const { Server } = require("socket.io")
const { db } = require("./src/prisma/db.ts")

dotenv.config();
const app = express();
const server = http.createServer(app)

const onlineUsers = {}
//Socket.io setup
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for now
        // Allows connections from ANY website/domain
        methods: ["GET", "POST"]//Only allow GET and POST requests
    }
})

const PORT = process.env.PORT || 5002;
app.use(express.json());
app.use(cookieParser());
app.use(cors())

const authRouter = require('./src/routes/authroutes.js')
const accountsRouter = require('./src/routes/accountRoutes.js')
const requestsRouter = require('./src/routes/friendRequests.js')
const chatRouter = require('./src/routes/chatRoutes.js')

app.use('/api/auth',authRouter)
app.use('/api/accounts',accountsRouter)
app.use('/api/requests', requestsRouter)
app.use('/api/chats', chatRouter)

io.on('connection', (socket) => {
    console.log('New client connected')

    const userId = socket.handshake.query.userId;
    if (userId) {
        onlineUsers[userId] = socket.id
        console.log(`User ${userId} connected`)
    }

    socket.on('disconnect', () => {
        delete onlineUsers[userId]
        console.log('User disconnected')
    })

    socket.on('sendMessage', async (data) => {
        const message = data
        const amount = Number(data.amount)
        try {
            const addMessage = await db.orm.public.Owes.create({
                senderId: message.senderId,
                receiverId: message.receiverId,
                amount: amount,
                detail: message.detail
            })

            //Emitting message to receiver only
            //const senderId = onlineUsers[data.senderId]
            const receiverId = onlineUsers[data.receiverId]
            /*if (senderId) {
                console.log('Emitting to senderId')
                io.to(senderId.toString()).emit('receiveMessage', addMessage)
            }*/
            if (receiverId) {
                io.to(receiverId.toString()).emit('receiveMessage', addMessage)

            }

        } catch (e) {
            console.error('Error saving message to database: ',e)
        }
    })
})

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
})

module.exports = app;