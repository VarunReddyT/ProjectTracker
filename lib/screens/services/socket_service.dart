import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  bool _isConnected = false;
  String? _url;

  bool get isConnected => _isConnected;

  SocketService(String url) {
    _url = url;
    connect();
  }

  void connect() {
    try {
      // Disconnect if already connected
      if (_isConnected) {
        socket.disconnect();
      }

      socket = IO.io(
        _url!,
        IO.OptionBuilder()
          .setTransports(['websocket']) // Force WebSocket transport
          .enableAutoConnect() // Enable auto-connection
          .enableReconnection() // Enable reconnection
          .setReconnectionAttempts(5) // Number of reconnection attempts
          .setReconnectionDelay(1000) // Delay between reconnections in ms
          .setTimeout(5000) // Connection timeout
          .setQuery({'platform': 'flutter'})
          .build(),
      );

      // Connection established
      socket.onConnect((_) {
        _isConnected = true;
        notifyListeners();
        print('Socket connected to $_url');
      });

      // Connection lost
      socket.onDisconnect((_) {
        _isConnected = false;
        notifyListeners();
        print('Socket disconnected');
      });

      // Connection error
      socket.onConnectError((err) {
        _isConnected = false;
        notifyListeners();
        print('Connection error: $err');
      });

      // Connect to the server
      socket.connect();

    } catch (e) {
      print('Socket initialization error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void sendMessage(String event, dynamic data) {
    if (!_isConnected) {
      print('Not connected to server, attempting to reconnect...');
      connect();
      return;
    }
    
    try {
      print('Sending $event: $data');
      socket.emit(event, data);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void onMessage(String event, Function(dynamic) callback) {
    socket.on(event, (data) {
      try {
        print('Received $event: $data');
        callback(data);
      } catch (e) {
        print('Message handling error: $e');
      }
    });
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
      notifyListeners();
    }
  }
}