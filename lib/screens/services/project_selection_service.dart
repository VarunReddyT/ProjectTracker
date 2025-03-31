import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProjectSelectionService extends ChangeNotifier {
  late IO.Socket socket;
  bool isAdmin = false;
  
  Future<void> initialize(String url, {bool isAdmin = false}) async {
    this.isAdmin = isAdmin;
    socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setPath('/socket.io')
        .setAuth({'isAdmin' : isAdmin})
        .setExtraHeaders({"Access-Control-Allow-Origin": "*"})
        .build());

    socket.onConnect((_) => debugPrint('Connected'));
    socket.onDisconnect((_) => debugPrint('Disconnected'));
    socket.onError((err) => debugPrint('Error: $err'));

    socket.connect();
  }

void startProjectSelection(int year){
  if(isAdmin){
    socket.emit('admin_start_selection', {'targetYear' : year});
  }else{
    socket.emit('auth_error', {'message' : 'You are not authorized to start project selection'});
  }
}

void stopProjectSelection(int year){
  if(isAdmin){
    socket.emit('admin_stop_selection');
  }else{
    socket.emit('auth_error', {'message' : 'You are not authorized to stop project selection'});
  }
}

void teamSelectProject(String teamId, String projectId) {
  if(!isAdmin){
    socket.emit('team_select_project', {
      'teamId': teamId,
      'projectId': projectId,
    });
  }else{
    socket.emit('select_error', {'message' : 'You are not a student'});
  }
}

  void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}