// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:time/tsheets_manager.dart';

class DebugMenu extends StatefulWidget {
  const DebugMenu({Key? key}) : super(key: key);

  @override
  State<DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  final manager = SheetsManager.instance;

  List<(String, Function)> functionList = [];

  List<Widget> children = [];
  @override
  void initState() {
    super.initState();

    functionList = [
      (
        'Get JobCodes',
        () async {
          List<JobCodes> x = await getJobcodes();
          for (var y in x) {
            print(y.name);
          }
          inspect(x);
        }
      ),
      (
        'Get JobCode Assignments',
        () async {
          List<JobCodeAssignment> x = await getJobcodeAssignments();
          inspect(x);
        }
      ),
      (
        'Get Projects',
        () async {
          List<Project> x = await getProjects();
          for (var y in x) {
            print(y.name);
          }
          inspect(x);
        }
      ),
      (
        'View My Jobs',
        () async {
          inspect(manager.assignedJobs);
        }
      ),
    ];
    for (var child in functionList) {
      children.add(_buildDebugButton(child.$1, child.$2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Debug Menu'),
      ),
      body: Center(
        child: Wrap(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDebugButton(String title, Function function) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: PlatformElevatedButton(
        child: Text(title),
        onPressed: () => function(),
      ),
    );
  }
}
