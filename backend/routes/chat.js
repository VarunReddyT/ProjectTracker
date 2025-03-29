const { Message, ChatRoom } = require('../models/chat');

const SocketRoutes = (io) => {
    io.on("connection", (socket) => {
        console.log(`User connected : ${socket.id}`);

        socket.on('error', (err) => {
            console.error('Socket error:', err.message);
            socket.emit('message_error', {error : err.message});
        });

        socket.on("join_room", async ({ chatRoomId, userId }) => {
            try {
                const room = await ChatRoom.findOne({ _id: chatRoomId, participants: userId })
                                           .populate("participants", "username");

                if (!room || room.participants.length === 0) {
                    return socket.emit("error", { message: "Room not found" });
                }

                socket.join(chatRoomId);
                console.log(`User ${userId} joined room ${chatRoomId}`);

                const otherUser = room.participants.find(p => p._id.toString() !== userId);
                socket.to(chatRoomId).emit("user_joined", { userId, username: otherUser?.username });
            } 
            catch (err) {
                socket.emit("error", { message: "Failed to join room" });
            }
        });

        socket.on("send_message", async ({ chatRoomId, userId, message }) => {
            console.log(`User ${userId} sent message in room ${chatRoomId}. Message : ${message}`);
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
                console.log(savedMessage);

                await ChatRoom.findByIdAndUpdate(chatRoomId, {
                    lastMessage: savedMessage._id,
                    updatedAt: new Date()
                });

                const populatedMessage = await Message.populate(savedMessage, { path: "sender", select: "username" });

                io.to(chatRoomId).emit("new_message", {
                    message: populatedMessage.toObject(),
                    timestamp: new Date(populatedMessage.timestamp).toISOString()
                });

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
    });
}

module.exports = { SocketRoutes };
