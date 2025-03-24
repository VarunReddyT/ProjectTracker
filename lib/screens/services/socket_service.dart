import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Connect to the Socket.IO server
  void connect(String url) {
    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'], // Use WebSocket transport
      'autoConnect': true, // Automatically connect
    });

    // Listen for connection event
    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    // Listen for disconnection event
    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    // Handle connection errors
    socket.onError((error) {
      print('Socket.IO error: $error');
    });
  }

  // Send a message to the server
  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  // Listen for messages from the server
  void onMessage(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  // Disconnect from the server
  void disconnect() {
    socket.disconnect();
  }
}