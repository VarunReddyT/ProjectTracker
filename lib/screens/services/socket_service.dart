import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier{
  late IO.Socket socket;
  bool isConnected = false;

  SocketService(String url) {
    connect(url);
  }

  void connect(String url) {
    try {
      socket = IO.io(
        url,
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'platform': 'flutter'})
          .build(),
      );

      socket.onConnect((_) {
        isConnected = true;
        notifyListeners();
        print('Connected');
      });

      socket.onDisconnect((_) {
        isConnected = false;
        notifyListeners();
        print('Disconnected');
      });

      socket.connect();
    } catch (e) {
      print('Connection error: $e');
    }
  }

  void sendMessage(String event, dynamic data) {
    if (isConnected) {
      socket.emit(event, data);
    } else {
      print('Not connected to the server');
    }
    // print('Sending message');
  }

  void onMessage(String event, Function(dynamic) callback) {
    socket.on(event, (data) {
      try {
        callback(data);
      } catch (e) {
        print('Message handling error: $e');
      }
    });
  }

  void disconnect() {
    if (isConnected) {
      socket.disconnect();
      isConnected = false;
    }
  }
}
