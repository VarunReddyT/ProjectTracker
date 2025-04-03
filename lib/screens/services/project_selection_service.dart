import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProjectSelectionService extends ChangeNotifier {
  late IO.Socket socket;
  bool isAdmin = false;
  int? selectedYear;
  late StreamController<Map<String, dynamic>> _errorController;

  Stream<Map<String, dynamic>> get errorStream => _errorController.stream;

  late StreamController<List<Map<String, dynamic>>> _projectsController;

  Stream<List<Map<String, dynamic>>> get projectsStream => _projectsController.stream;

   ProjectSelectionService() {
    _initializeControllers();
  }

  void _initializeControllers() {
    _errorController = StreamController<Map<String, dynamic>>.broadcast();
    _projectsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  }

  int get getSelectedYear => selectedYear ?? 0;
  bool get isSelectionActive => selectedYear != null;
  
  void _safeAddError(Map<String, dynamic> error) {
    if (!_errorController.isClosed) {
      _errorController.add(error);
    } else {
      debugPrint('Error controller closed when trying to add: $error');
    }
  }

  void _safeAddProjects(List<Map<String, dynamic>> projects) {
    if (!_projectsController.isClosed) {
      _projectsController.add(projects);
    } else {
      debugPrint('Projects controller closed when trying to add projects');
    }
  }

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
    socket.onError((err) => _safeAddError({
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

    socket.on('display_projects', (data) {
      try {
        final projects = List<Map<String, dynamic>>.from(data['projects']);
        _safeAddProjects(projects);
      } catch (e) {
        _safeAddError({
          'code': 'DATA_ERROR',
          'message': 'Failed to parse projects: ${e.toString()}'
        });
      }
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
  try {
    socket.emit('request_projects', {
      'targetYear': year,
    });
  } catch (e) {
    _errorController.add({
      'code': 'FETCH_ERROR',
      'message': 'Failed to fetch projects: ${e.toString()}',
    });
  }
}

 void disconnect() {
    try {
      socket.disconnect();
      socket.dispose();
    } catch (e) {
      debugPrint('Error disconnecting socket: ${e.toString()}');
    } finally {
      _closeControllers();
    }
  }

  void _closeControllers() {
    if (!_errorController.isClosed) {
      _errorController.close();
    }
    if (!_projectsController.isClosed) {
      _projectsController.close();
    }
  }
}