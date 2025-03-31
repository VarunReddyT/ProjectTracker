import 'package:flutter/material.dart';
import 'package:project_tracker/screens/services/project_selection_service.dart';
import 'package:provider/provider.dart';

class ManageProjectSelection extends StatefulWidget {
  const ManageProjectSelection({super.key});

  @override
  State<ManageProjectSelection> createState() => _ManageProjectSelectionState();
}

class _ManageProjectSelectionState extends State<ManageProjectSelection> {
  int? selectedYear;
  bool isLoading = false;
  late final ProjectSelectionService projectSelectionService;

  @override
  void initState() {
    super.initState();
    projectSelectionService = Provider.of<ProjectSelectionService>(context, listen: false);
  }

  Future<void> handleStartProjectSelection() async {
    if (selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await projectSelectionService.initialize(
        "ws://192.168.0.158:4000", 
        isAdmin: true,
      );
      projectSelectionService.startProjectSelection(selectedYear!);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project selection started for year $selectedYear')),
        );
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleStopProjectSelection() async {
    if (selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      projectSelectionService.stopProjectSelection(selectedYear!);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project selection stopped for year $selectedYear')),
        );
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Project Selection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/viewProjects');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<int>(
                value: selectedYear,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Year 1'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Year 2'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Year 3'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('Year 4'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => value == null ? 'Please select a year' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : handleStartProjectSelection,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Start Project Selection'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : handleStopProjectSelection,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.red,
                ),
                child: isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Stop Project Selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}