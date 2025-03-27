import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier{
  late IO.Socket socket;

  SocketService(String url) {
    socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setPath('/socket.io')
        .setExtraHeaders({"Access-Control-Allow-Origin": "*"})
        .build());

    socket.onConnect((_) => debugPrint('Connected'));
    socket.onDisconnect((_) => debugPrint('Disconnected'));
    socket.onError((err) => debugPrint('Error: $err'));

    socket.connect();
  }

  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  void onMessage(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
