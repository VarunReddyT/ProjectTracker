import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tracker/screens/services/socket_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;

  const ChatScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  String? _userId;
  String? _username;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    _loadUserData();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (_userId == null) return;
    try {
      final response = await http.get(
        Uri.parse(
            'https://ps-project-tracker.vercel.app/api/chat/getMessages/${widget.chatRoomId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(data.reversed.cast<Map<String, dynamic>>());
        });
        _scrollToBottom();
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load messages')),
          );
        }
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching messages: $e')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('studentId');
    _username = prefs.getString('username') ?? 'Anonymous';

    if (_userId != null) {
      _joinChatRoom();
      _setupSocketListeners();
    }
    setState(() {});
  }

  void _setupSocketListeners() {
    _socketService.onMessage('new_message', (data) {

      if (mounted && data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is Map<String, dynamic>) {
          setState(() {
            _messages.insert(0, {
              'userId': message['sender']['_id'],
              'message': message['content'],
              'timestamp': message['timestamp'],
              'sender': message['sender'],
            });
          });
          _scrollToBottom();
        }
      }
    });

    _socketService.onMessage('chat_history', (data) {
      if (mounted && data is List) {
        setState(() {
          _messages.clear();
          _messages.addAll(data.reversed.cast<Map<String, dynamic>>());
        });
        _scrollToBottom();
      }
    });

    _socketService.onMessage('message_error', (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    });
  }

  void _joinChatRoom() {
    _socketService.sendMessage('join_room', {
      'chatRoomId': widget.chatRoomId,
      'userId': _userId,
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty || _userId == null) return;

    final messageData = {
      'chatRoomId': widget.chatRoomId,
      'userId': _userId,
      'message': _controller.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'tempId': DateTime.now().millisecondsSinceEpoch.toString(),
      'sender': {'_id': _userId, 'username': _username},
    };

    _socketService.sendMessage('send_message', messageData);
    _controller.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['userId'] == _userId;

                return MessageBubble(
                  message: message['message'] ?? '',
                  isMe: isMe,
                  timestamp: message['timestamp'] ?? '',
                  sender: message['sender'] is Map<String, dynamic>
                      ? message['sender']['username'] ?? 'Unknown'
                      : 'Unknown',
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
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
    _scrollController.dispose();
    if (_userId != null) {
      _socketService.sendMessage('leave_room', {
        'chatRoomId': widget.chatRoomId,
        'userId': _userId,
      });
    }
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String timestamp;
  final String sender;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'You' : sender,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.blue : Colors.grey[700],
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
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
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
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
