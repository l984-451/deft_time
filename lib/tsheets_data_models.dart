// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

import 'package:codable/codable.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:time/tsheets_manager.dart';

part 'tsheets_data_models.g.dart';

final sheetsManager = SheetsManager.instance;

@JsonSerializable(explicitToJson: true)
class User extends Codable {
  int id;
  String? first_name;
  String? last_name;
  String? display_name;
  String? username;
  String? email;
  String? authToken;
  List<TimeSheet>? timesheets = [];
  List<JobCodes>? jobcodeAssignments = [];

  User({
    required this.id,
    this.first_name,
    this.last_name,
    this.display_name,
    this.username,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TimeEntry extends Codable {
  int user_id;
  String jobcode_id;
  String type;
  String start;
  String end;
  String notes;
  Map<String, dynamic> customfields;
  List<int> attached_files;
  TimeEntry({
    required this.user_id,
    required this.jobcode_id,
    required this.type,
    required this.start,
    required this.end,
    required this.notes,
    required this.customfields,
    required this.attached_files,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) => _$TimeEntryFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TimeEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TimeSheet {
  int? id;
  int? user_id;
  int? jobcode_id;
  int? locked;
  String? notes;
  bool? on_the_clock;
  int? created_by_user_id;
  String? start;
  String? end;
  String? date;
  int? duration;
  Map? customfields;
  TimeSheet({
    this.id,
    this.user_id,
    this.jobcode_id,
    this.locked,
    this.notes,
    this.on_the_clock,
    this.created_by_user_id,
    this.start,
    this.end,
    this.date,
    this.duration,
    this.customfields,
  });

  String get billable {
    int? billableId = sheetsManager.customFields.firstWhereOrNull((element) => element.name == 'Billable')?.id;
    return customfields?[billableId.toString()] ?? 'No';
  }

  factory TimeSheet.fromJson(Map<String, dynamic> json) => _$TimeSheetFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSheetToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JobCodeAssignment extends Codable {
  int id;
  int user_id;
  int jobcode_id;
  bool active;
  String last_modified;
  String created;
  JobCodeAssignment({
    required this.id,
    required this.user_id,
    required this.jobcode_id,
    required this.active,
    required this.last_modified,
    required this.created,
  });

  factory JobCodeAssignment.fromJson(Map<String, dynamic> json) => _$JobCodeAssignmentFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JobCodeAssignmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JobCodes extends Codable {
  int id;
  int parent_id;
  String name;
  String short_code;
  String type;
  bool billable;
  bool active;
  bool has_children;
  bool assigned_to_all;

  List<JobCodes> get subJobs {
    List<JobCodes> subJobs = [];
    // if (!has_children) return subJobs;
    for (var job in sheetsManager.allJobCodes) {
      if (job.parent_id == id) {
        subJobs.add(job);
      }
    }
    return subJobs;
  }

  List<Project> get projects {
    List<Project> subProjects = [];
    for (var project in sheetsManager.projects) {
      if (project.parent_jobcode_id == id) {
        subProjects.add(project);
      }
    }
    return subProjects;
  }

  JobCodes(
    this.id,
    this.parent_id,
    this.name,
    this.short_code,
    this.type,
    this.billable,
    this.active,
    this.has_children,
    this.assigned_to_all,
  );
  factory JobCodes.fromJson(Map<String, dynamic> json) => _$JobCodesFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JobCodesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JobDefaults extends Codable {
  JobCodes? job;
  String? billable;
  CustomFieldItem? serviceItem;
  String? notes;

  JobDefaults(
    this.job,
    this.billable,
    this.serviceItem,
    this.notes,
  );

  factory JobDefaults.fromJson(Map<String, dynamic> json) => _$JobDefaultsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JobDefaultsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Project extends Codable {
  int id;
  String name;
  int jobcode_id;
  int parent_jobcode_id;
  String description;
  String status;
  String start_date;
  String due_date;
  String completed_date;
  bool active;

  Project(
    this.id,
    this.name,
    this.jobcode_id,
    this.parent_jobcode_id,
    this.description,
    this.status,
    this.start_date,
    this.due_date,
    this.completed_date,
    this.active,
  );
  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomFields extends Codable {
  int id;
  bool active;
  String name;
  String short_code;
  bool show_to_all;
  bool required;
  String applies_to;
  String type;
  String ui_preference;
  String created;
  List required_customfields;

  CustomFields({
    required this.id,
    required this.active,
    required this.name,
    required this.short_code,
    required this.show_to_all,
    required this.required,
    required this.applies_to,
    required this.type,
    required this.ui_preference,
    required this.created,
    required this.required_customfields,
  });

  List<CustomFields> get items {
    List<CustomFields> tempList = [];

    for (var filter in sheetsManager.customFieldItemFilters) {
      if (filter.customfield_id == id) {
        tempList.add(this);
      }
    }

    return tempList;
  }

  factory CustomFields.fromJson(Map<String, dynamic> json) => _$CustomFieldsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CustomFieldsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomFieldItem extends Codable {
  int id;
  int customfield_id;
  String name;
  String short_code;
  bool active;
  String last_modified;
  List<int> required_customfields;

  CustomFieldItem(
    this.id,
    this.customfield_id,
    this.name,
    this.short_code,
    this.active,
    this.last_modified,
    this.required_customfields,
  );

  factory CustomFieldItem.fromJson(Map<String, dynamic> json) => _$CustomFieldItemFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CustomFieldItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomFieldItemFilter extends Codable {
  int id;
  int customfield_id;
  int customfielditem_id;
  String applies_to;
  int applies_to_id;
  bool active;
  String last_modified;

  CustomFieldItemFilter(
    this.id,
    this.customfield_id,
    this.customfielditem_id,
    this.applies_to,
    this.applies_to_id,
    this.active,
    this.last_modified,
  );

  factory CustomFieldItemFilter.fromJson(Map<String, dynamic> json) => _$CustomFieldItemFilterFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CustomFieldItemFilterToJson(this);
}
