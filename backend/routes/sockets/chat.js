const { Message, ChatRoom } = require('../../models/chat');

const SocketRoutes = (io) => {
    io.on("connection", (socket) => {
        console.log(`User connected: ${socket.id}`);

        // Error handling middleware
        socket.use(([event, ...args], next) => {
            try {
                next();
            } catch (err) {
                console.error('Socket middleware error:', err);
                socket.emit('socket_error', { 
                    event,
                    error: err.message 
                });
            }
        });

        // Join room with enhanced data
        socket.on("join_room", async ({ chatRoomId, userId }) => {
            try {
                const room = await ChatRoom.findOne({ 
                    _id: chatRoomId, 
                    participants: userId 
                }).populate("participants", "username avatar")
                  .populate("lastMessage");

                if (!room) {
                    return socket.emit("room_error", { 
                        chatRoomId,
                        message: "Room not found or access denied" 
                    });
                }

                socket.join(chatRoomId);
                console.log(`User ${userId} joined room ${chatRoomId}`);

                // Send room details to the user
                socket.emit("room_details", {
                    name: room.name,
                    isGroupChat: room.isGroupChat,
                    participants: room.participants,
                    lastMessage: room.lastMessage
                });

                // Notify others in the room
                socket.to(chatRoomId).emit("user_joined", {
                    userId,
                    username: room.participants.find(p => p._id.equals(userId))?.username,
                    timestamp: new Date()
                });

                // Send last 50 messages
                const messages = await Message.find({ chatRoomId })
                    .sort({ timestamp: -1 })
                    .limit(50)
                    .populate("sender", "username avatar")
                    .lean();

                socket.emit("initial_messages", messages.reverse());

            } catch (err) {
                console.error("Join room error:", err);
                socket.emit("room_error", { 
                    chatRoomId,
                    message: "Failed to join room" 
                });
            }
        });

        // Enhanced message handling
        socket.on("send_message", async ({ chatRoomId, userId, message, tempId }) => {
            try {
                if (!chatRoomId || !userId || !message?.trim()) {
                    return socket.emit("message_error", {
                        tempId,
                        message: "Invalid message data"
                    });
                }

                const room = await ChatRoom.findOne({ 
                    _id: chatRoomId, 
                    participants: userId 
                });

                if (!room) {
                    return socket.emit("message_error", {
                        tempId,
                        message: "Room not found"
                    });
                }

                const newMessage = new Message({
                    chatRoomId,
                    sender: userId,
                    content: message.trim(),
                    status: 'sent'
                });

                const savedMessage = await newMessage.save();
                await ChatRoom.findByIdAndUpdate(chatRoomId, {
                    lastMessage: savedMessage._id,
                    updatedAt: new Date()
                });

                const populatedMessage = await Message.populate(savedMessage, {
                    path: "sender",
                    select: "username avatar"
                });

                // Confirm delivery to sender
                socket.emit("message_delivered", {
                    tempId,
                    messageId: savedMessage._id,
                    timestamp: new Date()
                });

                // Broadcast to room
                io.to(chatRoomId).emit("new_message", {
                    message: populatedMessage.toObject(),
                    status: 'delivered'
                });

            } catch (err) {
                console.error("Send message error:", err);
                socket.emit("message_error", {
                    tempId,
                    message: "Failed to send message"
                });
            }
        });

        // Typing indicators with debouncing
        const typingUsers = new Map();
        
        socket.on('typing', ({ chatRoomId, userId, isTyping }) => {
            try {
                if (!typingUsers.has(chatRoomId)) {
                    typingUsers.set(chatRoomId, new Set());
                }

                const roomTypingUsers = typingUsers.get(chatRoomId);
                if (isTyping) {
                    roomTypingUsers.add(userId);
                } else {
                    roomTypingUsers.delete(userId);
                }

                // Broadcast to room
                socket.to(chatRoomId).emit('typing', {
                    userIds: Array.from(roomTypingUsers),
                    isTyping: roomTypingUsers.size > 0
                });

            } catch (err) {
                console.error("Typing indicator error:", err);
            }
        });

        // Message read receipts
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
                        },
                        status: 'read'
                    },
                    { new: true }
                ).populate("sender", "username");

                if (!message) {
                    return socket.emit("read_error", {
                        messageId,
                        error: "Message not found"
                    });
                }

                io.to(message.chatRoomId.toString()).emit("message_read", {
                    messageId,
                    userId,
                    readAt: new Date()
                });

            } catch (err) {
                console.error("Read receipt error:", err);
                socket.emit("read_error", {
                    messageId,
                    error: "Failed to mark as read"
                });
            }
        });

        // Cleanup on disconnect
        socket.on("disconnect", () => {
            console.log(`User disconnected: ${socket.id}`);
            typingUsers.forEach((users, roomId) => {
                users.forEach(userId => {
                    socket.to(roomId).emit('typing', {
                        userId,
                        isTyping: false
                    });
                });
            });
        });
    });
};

module.exports = { SocketRoutes };