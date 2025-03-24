const { Message, ChatRoom } = require('../models/chat');
const { getIO } = require('../socket');

const SocketRoutes = () => {
    const io = getIO();
    io.on("connection", (socket) => {
        console.log(`User connected : ${socket.id}`);

        socket.on("join_room", async ({ chatRoomId, userId }) => {
            try {
                const room = await ChatRoom.find({ _id: chatRoomId, participants: userId }).populate("participants", "username");
                if (!room) {
                    return socket.emit("error", { message: "Room not found" });
                }
                socket.join(chatRoomId);
                console.log(`User ${userId} joined room ${chatRoomId}`);

                socket.to(chatRoomId).emit("user_joined", { userId, username: room.participants.find(p => p._id.toString() !== userId).username });
            }
            catch (err) {
                socket.emit("error", { message: "Failed to join room" });
            }
        });

        socket.on("send_message", async ({ chatRoomId, userId, message }) => {
            if (!chatRoomId || !userId || !message) {
                return socket.emit("error", { message: "Invalid data" });
            }
            try {
                const room = await ChatRoom.findOne({ _id: chatRoomId, participants: userId });
                if (!room) {
                    return socket.emit("error", { message: "Room not found" });
                }
                const newMessage = new Message({
                    chatRoomId,
                    sender: userId,
                    content: message
                });
                const savedMessage = await newMessage.save();

                await ChatRoom.findByIdAndUpdate(chatRoomId, {
                    lastMessage: savedMessage._id,
                    updatedAt: new Date()
                });

                const populateMessage = await Message.populate(savedMessage, { path: "sender", select: "username" });

                io.to(chatRoomId).emit("new_message", populateMessage.toObject(),
                    timestamp = new Date(populateMessage.timestamp).toISOString());

            }
            catch (err) {
                socket.emit("error", { message: err.message });
            }
        });

        socket.on('typing', ({ chatRoomId, userId, isTyping }) => {
            socket.to(chatRoomId).emit('typing', { userId, isTyping });
        });

        socket.on('mark_as_read', async ({ messageId, userId }) => {
            try {
                const message = await Message.findByIdAndUpdate(
                    messageId,
                    {
                        $addToSet: {
                            readBy: {
                                readerId: userId,
                                readAt: new Date()
                            }
                        }
                    },
                    { new: true }
                );
                if (!message) {
                    return socket.emit("error", { message: "Message not found" });
                }
                io.to(message.chatRoomId.toString()).emit("message_read", { 
                    messageId, 
                    userId 
                });
            }
            catch (err) {
                socket.emit("error", { message: err.message });
            }
        });

        socket.on("disconnect", () => {
            console.log(`User disconnected : ${socket.id}`);
        });
    })
}

module.exports = SocketRoutes;