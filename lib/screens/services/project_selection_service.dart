import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProjectSelectionService extends ChangeNotifier {
  late IO.Socket socket;
  bool isAdmin = false;
  int? selectedYear;
  final StreamController<Map<String, dynamic>> _errorController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get errorStream => _errorController.stream;

  final StreamController<List<Map<String, dynamic>>> _projectsController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get projectsStream => _projectsController.stream;

  int get getSelectedYear => selectedYear ?? 0;
  bool get isSelectionActive => selectedYear != null;
  
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
    socket.onError((err) => _errorController.add({
      'code': 'CONNECTION_ERROR',
      'message': err.toString()      
      }));

    socket.on('release_error', (data) {
      _errorController.add({
        'code': 'RELEASE_ERROR',
        'message': data['message'],
      });
    });

    socket.on('no_projects', (data) {
      _errorController.add({
        'code': 'NO_PROJECTS',
        'message': data['message'],
      });
    });

    socket.on('selection_error', (data) {
      _errorController.add({
        'code': 'SELECTION_ERROR',
        'message': data['message'],
      });
    });

    socket.on('projects_released', (data) {
      selectedYear = data['targetYear'];
      notifyListeners();
    });

    socket.on('projects_selection_ended', (data) {
      selectedYear = null;
      notifyListeners();
    });

    socket.on('display_projcets',(data){
      final projects = List<Map<String, dynamic>>.from(data['projects']);
      _projectsController.add(projects);
    });


    socket.connect();
  }

void startProjectSelection(int year){
  if(isAdmin){
    socket.emit('admin_start_selection', {'targetYear' : year});
  }else{
    _errorController.add({
      'code': 'AUTH_ERROR',
      'message': 'You are not authorized to start project selection',
    });
  }
}

void stopProjectSelection(int year){
  if(isAdmin && selectedYear != null && selectedYear == year){
    socket.emit('admin_stop_selection');
  }else{
    _errorController.add({
      'code': 'AUTH_ERROR',
      'message': 'You are not authorized to stop project selection',
    });
  }
}

void teamSelectProject(String teamId, String projectId) {
  if(!isAdmin){
    socket.emit('team_select_project', {
      'teamId': teamId,
      'projectId': projectId,
    });
  }else{
    _errorController.add({
      'code': 'AUTH_ERROR',
      'message': 'You are not a student',
    });
  }
}

void getProjects(int year){
  socket.emit('display_projects', {
    'targetYear': year,
  });
}

  void disconnect() {
    socket.disconnect();
    socket.dispose();
    _errorController.close();
  }
}