const { server } = require("../server")
const { Server } = require("socket.io")
const { db } = require("./prisma/db")

const onlineUsers = {}
//Socket.io setup
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for now
        // Allows connections from ANY website/domain
        methods: ["GET", "POST"]//Only allow GET and POST requests
    }
})

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

            //Emitting message to both sender and receiver
            const senderId = onlineUsers[data.senderId]
            const receiverId = onlineUsers[data.receiverId]
            if (senderId) {
                io.to(senderId.toString()).emit('receiveMessage', addMessage)
            }
            if (receiverId) {
                io.to(receiverId.toString()).emit('receiveMessage', addMessage)

            }

        } catch (e) {
            console.error('Error saving message to database: ',e)
        }
    })
})

