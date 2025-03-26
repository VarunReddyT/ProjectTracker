import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;

  const ChatScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  String? userId;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    _loadUserData();
    _setupSocketListeners();
    _joinChatRoom();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('studentId');
    });
  }

  void _setupSocketListeners() {
    _socketService.onMessage('new_message', (data) {
      if (mounted && data is Map<String, dynamic>) {
        setState(() => messages.add(data));
      }
    });

    _socketService.onMessage('message_error', (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    });
  }

  void _joinChatRoom() {
    if (userId != null) {
      _socketService.sendMessage('join_room', {
        'chatRoomId': widget.chatRoomId,
        'userId': userId,
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty || userId == null) return;

    final messageData = {
      'chatRoomId': widget.chatRoomId,
      'userId': userId,
      'message': _controller.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socketService.sendMessage('send_message', messageData);
    _controller.clear();

    // Optimistically add the message to the UI
    setState(() {
      messages.add({
        ...messageData,
        'status': 'sending', // You can use this to show sending status
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room: ${widget.chatRoomId.substring(0, 6)}...'),
      ),
      body: Column(
        children: [
          Consumer<SocketService>(
            builder: (context, socketService, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: socketService.isConnected ? Colors.green : Colors.red,
                child: Center(
                  child: Text(
                    socketService.isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // Newest messages at the bottom
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message['userId'] == userId;
                
                return MessageBubble(
                  message: message['message'],
                  isMe: isMe,
                  timestamp: message['timestamp'],
                  status: message['status'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Leave the chat room when the screen is disposed
    if (userId != null) {
      _socketService.sendMessage('leave_room', {
        'chatRoomId': widget.chatRoomId,
        'userId': userId,
      });
    }
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String timestamp;
  final String? status;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                if (isMe && status != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    status == 'sending' ? Icons.access_time : Icons.done,
                    size: 12,
                    color: status == 'delivered' ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final time = DateTime.parse(isoTime);
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoTime;
    }
  }
}