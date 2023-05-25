// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tsheets_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      display_name: json['display_name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
    )
      ..authToken = json['authToken'] as String?
      ..timesheets = (json['timesheets'] as List<dynamic>?)
          ?.map((e) => TimeSheet.fromJson(e as Map<String, dynamic>))
          .toList()
      ..jobcodeAssignments = (json['jobcodeAssignments'] as List<dynamic>?)
          ?.map((e) => JobCodes.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'display_name': instance.display_name,
      'username': instance.username,
      'email': instance.email,
      'authToken': instance.authToken,
      'timesheets': instance.timesheets?.map((e) => e.toJson()).toList(),
      'jobcodeAssignments':
          instance.jobcodeAssignments?.map((e) => e.toJson()).toList(),
    };

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => TimeEntry(
      user_id: json['user_id'] as int,
      jobcode_id: json['jobcode_id'] as String,
      type: json['type'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      notes: json['notes'] as String,
      customfields: json['customfields'] as Map<String, dynamic>,
      attached_files: (json['attached_files'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$TimeEntryToJson(TimeEntry instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'jobcode_id': instance.jobcode_id,
      'type': instance.type,
      'start': instance.start,
      'end': instance.end,
      'notes': instance.notes,
      'customfields': instance.customfields,
      'attached_files': instance.attached_files,
    };

TimeSheet _$TimeSheetFromJson(Map<String, dynamic> json) => TimeSheet(
      id: json['id'] as int?,
      user_id: json['user_id'] as int?,
      jobcode_id: json['jobcode_id'] as int?,
      locked: json['locked'] as int?,
      notes: json['notes'] as String?,
      on_the_clock: json['on_the_clock'] as bool?,
      created_by_user_id: json['created_by_user_id'] as int?,
      start: json['start'] as String?,
      end: json['end'] as String?,
      date: json['date'] as String?,
      duration: json['duration'] as int?,
      customfields: json['customfields'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TimeSheetToJson(TimeSheet instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'jobcode_id': instance.jobcode_id,
      'locked': instance.locked,
      'notes': instance.notes,
      'on_the_clock': instance.on_the_clock,
      'created_by_user_id': instance.created_by_user_id,
      'start': instance.start,
      'end': instance.end,
      'date': instance.date,
      'duration': instance.duration,
      'customfields': instance.customfields,
    };

JobCodeAssignment _$JobCodeAssignmentFromJson(Map<String, dynamic> json) =>
    JobCodeAssignment(
      id: json['id'] as int,
      user_id: json['user_id'] as int,
      jobcode_id: json['jobcode_id'] as int,
      active: json['active'] as bool,
      last_modified: json['last_modified'] as String,
      created: json['created'] as String,
    );

Map<String, dynamic> _$JobCodeAssignmentToJson(JobCodeAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'jobcode_id': instance.jobcode_id,
      'active': instance.active,
      'last_modified': instance.last_modified,
      'created': instance.created,
    };

JobCodes _$JobCodesFromJson(Map<String, dynamic> json) => JobCodes(
      json['id'] as int,
      json['parent_id'] as int,
      json['name'] as String,
      json['short_code'] as String,
      json['type'] as String,
      json['billable'] as bool,
      json['active'] as bool,
      json['has_children'] as bool,
      json['assigned_to_all'] as bool,
    );

Map<String, dynamic> _$JobCodesToJson(JobCodes instance) => <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parent_id,
      'name': instance.name,
      'short_code': instance.short_code,
      'type': instance.type,
      'billable': instance.billable,
      'active': instance.active,
      'has_children': instance.has_children,
      'assigned_to_all': instance.assigned_to_all,
    };

JobDefaults _$JobDefaultsFromJson(Map<String, dynamic> json) => JobDefaults(
      json['job'] == null
          ? null
          : JobCodes.fromJson(json['job'] as Map<String, dynamic>),
      json['parentJob'] == null
          ? null
          : JobCodes.fromJson(json['parentJob'] as Map<String, dynamic>),
      json['billable'] as String?,
      json['serviceItem'] == null
          ? null
          : CustomFieldItem.fromJson(
              json['serviceItem'] as Map<String, dynamic>),
      json['notes'] as String?,
    );

Map<String, dynamic> _$JobDefaultsToJson(JobDefaults instance) =>
    <String, dynamic>{
      'job': instance.job?.toJson(),
      'parentJob': instance.parentJob?.toJson(),
      'billable': instance.billable,
      'serviceItem': instance.serviceItem?.toJson(),
      'notes': instance.notes,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      json['id'] as int,
      json['name'] as String,
      json['jobcode_id'] as int,
      json['parent_jobcode_id'] as int,
      json['description'] as String,
      json['status'] as String,
      json['start_date'] as String,
      json['due_date'] as String,
      json['completed_date'] as String,
      json['active'] as bool,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'jobcode_id': instance.jobcode_id,
      'parent_jobcode_id': instance.parent_jobcode_id,
      'description': instance.description,
      'status': instance.status,
      'start_date': instance.start_date,
      'due_date': instance.due_date,
      'completed_date': instance.completed_date,
      'active': instance.active,
    };

CustomFields _$CustomFieldsFromJson(Map<String, dynamic> json) => CustomFields(
      id: json['id'] as int,
      active: json['active'] as bool,
      name: json['name'] as String,
      short_code: json['short_code'] as String,
      show_to_all: json['show_to_all'] as bool,
      required: json['required'] as bool,
      applies_to: json['applies_to'] as String,
      type: json['type'] as String,
      ui_preference: json['ui_preference'] as String,
      created: json['created'] as String,
      required_customfields: json['required_customfields'] as List<dynamic>,
    );

Map<String, dynamic> _$CustomFieldsToJson(CustomFields instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'name': instance.name,
      'short_code': instance.short_code,
      'show_to_all': instance.show_to_all,
      'required': instance.required,
      'applies_to': instance.applies_to,
      'type': instance.type,
      'ui_preference': instance.ui_preference,
      'created': instance.created,
      'required_customfields': instance.required_customfields,
    };

CustomFieldItem _$CustomFieldItemFromJson(Map<String, dynamic> json) =>
    CustomFieldItem(
      json['id'] as int,
      json['customfield_id'] as int,
      json['name'] as String,
      json['short_code'] as String,
      json['active'] as bool,
      json['last_modified'] as String,
      (json['required_customfields'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$CustomFieldItemToJson(CustomFieldItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customfield_id': instance.customfield_id,
      'name': instance.name,
      'short_code': instance.short_code,
      'active': instance.active,
      'last_modified': instance.last_modified,
      'required_customfields': instance.required_customfields,
    };

CustomFieldItemFilter _$CustomFieldItemFilterFromJson(
        Map<String, dynamic> json) =>
    CustomFieldItemFilter(
      json['id'] as int,
      json['customfield_id'] as int,
      json['customfielditem_id'] as int,
      json['applies_to'] as String,
      json['applies_to_id'] as int,
      json['active'] as bool,
      json['last_modified'] as String,
    );

Map<String, dynamic> _$CustomFieldItemFilterToJson(
        CustomFieldItemFilter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customfield_id': instance.customfield_id,
      'customfielditem_id': instance.customfielditem_id,
      'applies_to': instance.applies_to,
      'applies_to_id': instance.applies_to_id,
      'active': instance.active,
      'last_modified': instance.last_modified,
    };
