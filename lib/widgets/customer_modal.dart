import 'dart:developer';
import 'dart:math';

import 'package:codable/codable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:time/tsheets_manager.dart';

class CustomerModal extends StatefulWidget {
  final Function callback;
  final SharedPreferences prefs;
  const CustomerModal({Key? key, required this.callback, required this.prefs}) : super(key: key);

  @override
  State<CustomerModal> createState() => _CustomerModalState();
}

class _CustomerModalState extends State<CustomerModal> {
  final sheetsManager = SheetsManager.instance;
  List<JobCodes> localJobs = [];
  int _defaultJobCounter = 0;
  @override
  void initState() {
    super.initState();
    localJobs = sheetsManager.parentJobs;

    String defaultsString = widget.prefs.getString('jobDefaults') ?? '';
    List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
    int? recentJob = widget.prefs.getInt('jobRecent');
    JobDefaults? x;
    if (recentJob != null) {
      x = defaultList.firstWhereOrNull((element) => element.job?.id == recentJob);
      if (x != null) {
        defaultList.removeWhere((element) => element.job?.id == x!.job?.id);
        defaultList.insert(0, x);
      }
    }
    for (int i = 0; i < min(defaultList.length, 5); i++) {
      JobDefaults x = defaultList[i];
      inspect(x);
      if (x.job != null) {
        _defaultJobCounter++;
        localJobs.insert(i, x.job!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemBackground,
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index < _defaultJobCounter - 1) {
            return _buildListTile(context, localJobs[index], true);
          } else if (index == _defaultJobCounter - 1) {
            return Column(
              children: [
                _buildListTile(context, localJobs[index], true),
                const Divider(
                  thickness: 4,
                )
              ],
            );
          } else {
            return _buildListTile(context, localJobs[index], false);
          }
        },
        itemCount: localJobs.length,
      ),
    );
  }

  Widget? _trailingWidget(JobCodes item, bool isDefault) {
    if (isDefault) {
      return Icon(PlatformIcons(context).star);
    } else if (item.has_children) {
      return Icon(PlatformIcons(context).rightChevron);
    } else {
      return null;
    }
  }

  Widget _buildListTile(BuildContext context, JobCodes item, bool isDefault) {
    return PlatformListTile(
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing: _trailingWidget(item, isDefault),
      onTap: () {
        if (isDefault) {
          widget.callback(item.id);
        } else if (item.has_children) {
          showCupertinoModalBottomSheet(context: context, builder: (_) => CustomerDetailsPage(callback: widget.callback, jobCode: item));
        } else {
          widget.callback(item.id);
        }
      },
    );
  }
}

class CustomerDetailsPage extends StatelessWidget {
  final Function callback;
  final JobCodes jobCode;
  const CustomerDetailsPage({Key? key, required this.callback, required this.jobCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemBackground,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _buildListTile(context, jobCode.subJobs[index]);
        },
        itemCount: jobCode.subJobs.length,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, JobCodes item) {
    return PlatformListTile(
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing: item.has_children ? Icon(PlatformIcons(context).rightChevron) : const SizedBox.shrink(),
      onTap: () {
        if (item.has_children) {
          List<Project> projects = [];
          for (var project in sheetsManager.projects) {
            if (project.jobcode_id == item.id || project.parent_jobcode_id == item.id) {
              projects.add(project);
            }
          }
          showCupertinoModalBottomSheet(
            context: context,
            builder: (_) => ProjectPage(
              callback: callback,
              projects: projects,
            ),
          );
        } else {
          callback(item.id);
        }
      },
    );
  }
}

class ProjectPage extends StatelessWidget {
  final Function callback;
  final List<Project> projects;
  const ProjectPage({Key? key, required this.callback, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemBackground,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _buildListTile(context, projects[index]);
        },
        itemCount: projects.length,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Project item) {
    return PlatformListTile(
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        callback(item.jobcode_id);
      },
    );
  }
}
