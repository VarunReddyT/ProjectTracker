import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.onMessage('chat_message', (data) {
      if (data is String && mounted) {
        setState(() => messages.add(data));
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.sendMessage('chat_message', _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Consumer<SocketService>(
            builder: (context, socketService, child) {
              return Chip(
                label: Text(
                  socketService.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color:
                        socketService.isConnected ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
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
    super.dispose();
  }
}
