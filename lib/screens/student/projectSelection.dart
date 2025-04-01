import 'package:flutter/material.dart';
import 'package:project_tracker/screens/services/project_selection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProjectSelection extends StatefulWidget {
  const ProjectSelection({super.key});

  @override
  State<ProjectSelection> createState() => _ProjectSelectionState();
}

class _ProjectSelectionState extends State<ProjectSelection> {
  final ProjectSelectionService _projectService = ProjectSelectionService();
  String? _teamId;
  int? _studentYear;
  bool _isLoading = true;
  bool _hasSelectedProject = false;
  List<Map<String, dynamic>> _projects = [];
  String? _selectedProjectId;
  late Stream<Map<String, dynamic>> _errorSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _errorSubscription = _projectService.errorStream;
    _errorSubscription.listen((error) {
      _handleError(error);
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teamId = prefs.getString('teamId');
      _studentYear = prefs.getInt('studentYear');
      _isLoading = false;
    });

    if (_teamId != null && _studentYear != null) {
      await _initializeProjectSelection();
    }
  }

  Future<void> _initializeProjectSelection() async {
    _projectService.projectsStream.listen((projects) {
      setState(() {
        _projects = projects;
        print('Projects: $_projects');
      });
    });
    
    try {
      await _projectService.initialize(
        "ws://${dotenv.env['IP_ADDR']}:4000",
        isAdmin: false,
      );
      _projectService.getProjects(_studentYear!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: ${e.toString()}')),
        );
      }
    }
  }

  void _handleError(Map<String, dynamic> error) {
    if (!mounted) return;
    final code = error['code'] ?? 'UNKNOWN_ERROR';
    final message = error['message'] ?? 'An error occurred';

    switch(code){
      case 'CONNECTION_ERROR':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: $message')),
        );
        break;
      case 'RELEASE_ERROR':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Release Error: $message')),
        );
        break;
      case 'NO_PROJECTS':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No Projects: $message')),
        );
        break;
      case 'SELECTION_ERROR':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selection Error: $message')),
        );
        break;
      case 'AUTH_ERROR':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authorization Error: $message')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message')),
        );
        break;
    }
  }

  void _selectProject(String projectId) {
    if (_teamId == null) return;
    
    setState(() {
      _selectedProjectId = projectId;
    });
    
    _projectService.teamSelectProject(_teamId!, projectId);
  }

  @override
  void dispose() {
    _projectService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_teamId == null || _studentYear == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Selection')),
        body: const Center(
          child: Text('Team information not found. Please contact admin.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Project'),
        actions: [
          if (_hasSelectedProject)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: null,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team: $_teamId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Year: $_studentYear',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Projects:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _projects.isEmpty
                  ? const Center(child: Text('No projects available for selection'))
                  : ListView.builder(
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        final isSelected = _selectedProjectId == project['id'];
                        
                        return Card(
                          color: isSelected ? Colors.blue[50] : null,
                          child: ListTile(
                            title: Text(project['name']),
                            subtitle: Text(project['description']),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: () => _selectProject(project['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}