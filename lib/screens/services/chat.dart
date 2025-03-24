import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final SocketService _socketService;
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService.connect('http://192.168.0.156:4000');
    _setupSocket();
  }

  void _setupSocket() {
    _socketService.connect('http://192.168.0.156:4000');
    _socketService.onMessage('chat_message', (data) {
      if (data is String) {
        setState(() => messages.add(data));
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _socketService.sendMessage('chat_message', _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
    _socketService.disconnect();
    _controller.dispose();
    super.dispose();
  }
}
