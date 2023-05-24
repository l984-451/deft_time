import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:time/tsheets_manager.dart';

class CustomerModal extends StatelessWidget {
  final Function callback;
  const CustomerModal({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sheetsManager = SheetsManager.instance;
    return Container(
      color: CupertinoColors.systemBackground,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _buildListTile(context, sheetsManager.parentJobs[index]);
        },
        itemCount: sheetsManager.parentJobs.length,
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
          showCupertinoModalBottomSheet(context: context, builder: (_) => CustomerDetailsPage(callback: callback, jobCode: item));
        } else {
          callback(item.id);
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
