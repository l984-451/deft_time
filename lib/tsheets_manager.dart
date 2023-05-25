import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:codable/codable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/app_constants.dart';
import 'package:time/main.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:intl/intl.dart';

Future<List<User>> getUsers() async {
  List<User> users = [];
  final response = await http.get(Uri.parse('https://rest.tsheets.com/api/v1/users'), headers: {HttpHeaders.authorizationHeader: 'Bearer $koauthTokenBain'});

  final Map<String, dynamic> body = json.decode(response.body);

  final Map<String, dynamic> usersMap = body['results']['users'];
  for (Map<String, dynamic> user in usersMap.values) {
    User cUser = User.fromJson(user);
    if (cUser.first_name!.toLowerCase().contains('bain')) {
      // print('bain');
      cUser.authToken = koauthTokenBain;
    } else if (cUser.first_name!.toLowerCase().contains('austin')) {
      // print('austin');
      cUser.authToken = koauthTokenAustin;
    } else if (cUser.first_name!.toLowerCase().contains('andrew')) {
      // print('andrew');
      cUser.authToken = koauthTokenAndrew;
    } else if (cUser.first_name!.toLowerCase().contains('josh')) {
      // print('josh');
      cUser.authToken = koauthTokenJosh;
    } else if (cUser.first_name!.toLowerCase().contains('lisa')) {
      // print('lisa');
      cUser.authToken = koauthTokenLisa;
    } else if (cUser.first_name!.toLowerCase().contains('kyle')) {
      // print('kyle');
      cUser.authToken = koauthTokenKyle;
    } else if (cUser.first_name!.toLowerCase().contains('jonathan')) {
      // print('jonathan');
      cUser.authToken = koauthTokenJonathan;
    }

    if (cUser.first_name != 'DEFT') users.add(cUser);
  }
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('users', convertCodableListToString(users) ?? '');
  });
  return users;
}

Future<List<TimeSheet>> getUserTimeSheets() async {
  String? userId = globalUser?.id.toString();
  if (userId == null) return [];

  List<TimeSheet> sheets = [];
  final formatter = DateFormat('y-MM-dd');
  String startString = formatter.format(mostRecentWeekday(DateTime.now(), 1));
  String endString = formatter.format(DateTime.now());
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/timesheets?start_date=$startString&end_date=$endString&user_ids=$userId');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});
  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic>? results = body['results'];
  if (results != null) {
    final Map<String, dynamic> timeSheetMap = results['timesheets'];
    for (Map<String, dynamic> timesheet in timeSheetMap.values) {
      TimeSheet sheet = TimeSheet.fromJson(timesheet);
      sheets.add(sheet);
    }
  }

  return sheets;
}

Future<TimeSheet?> getCurrentStatus() async {
  String? userId = globalUser?.id.toString();
  if (userId == null) {
    return null;
  }
  final formatter = DateFormat('y-MM-dd');
  String sevenDayAgo = formatter.format(DateTime.now().subtract(const Duration(days: 7)));
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/timesheets?user_ids=$userId&on_the_clock=yes&start_date=$sevenDayAgo');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});
  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> timeSheetMap = body['results']['timesheets'];
  if (timeSheetMap.values.isNotEmpty) {
    return TimeSheet.fromJson(timeSheetMap.values.first);
  } else {
    return null;
  }
}

Future<List<JobCodes>> getJobcodes() async {
  List<JobCodes> codes = [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/jobcodes');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});
  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> jobCodeMap = body['results']['jobcodes'];
  for (Map<String, dynamic> jobCode in jobCodeMap.values) {
    JobCodes code = JobCodes.fromJson(jobCode);
    codes.add(code);
  }
  return codes;
}

Future<List<JobCodeAssignment>> getJobcodeAssignments() async {
  String? userId = globalUser?.id.toString();
  if (userId == null) return [];
  List<JobCodeAssignment> codes = [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/jobcode_assignments?user_ids=$userId');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});

  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> jobCodeMap = body['results']['jobcode_assignments'];
  for (Map<String, dynamic> jobCode in jobCodeMap.values) {
    JobCodeAssignment code = JobCodeAssignment.fromJson(jobCode);
    codes.add(code);
  }
  return codes;
}

Future<List<CustomFields>> getCustomFields() async {
  List<CustomFields> customFields = [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/customfields');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});

  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> customFieldsMap = body['results']['customfields'];
  for (Map<String, dynamic> jobCode in customFieldsMap.values) {
    CustomFields code = CustomFields.fromJson(jobCode);
    customFields.add(code);
  }
  return customFields;
}

Future<List<Project>> getProjects() async {
  List<Project> projectsTemp = [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/projects');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});

  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> projectsMap = body['results']['projects'];
  for (Map<String, dynamic> jobCode in projectsMap.values) {
    Project code = Project.fromJson(jobCode);
    projectsTemp.add(code);
  }
  return projectsTemp;
}

Future<List<CustomFieldItem>> getCustomFieldItems(int fieldId) async {
  List<CustomFieldItem> customFieldItems = [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/customfielditems?customfield_id=$fieldId');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});
  final Map<String, dynamic> body = json.decode(response.body);

  final Map<String, dynamic> customFieldItemsMap = body['results']['customfielditems'];
  for (Map<String, dynamic> customField in customFieldItemsMap.values) {
    CustomFieldItem code = CustomFieldItem.fromJson(customField);
    customFieldItems.add(code);
  }
  return customFieldItems;
}

Future<List<CustomFieldItemFilter>> getCustomFieldItemFilters() async {
  List<CustomFieldItemFilter> customFieldItemsFilters = [];
  String? userId = globalUser?.id.toString();
  if (userId == null) return [];
  Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/customfielditem_filters?user_id=$userId');
  final response = await http.get(requestUri, headers: {HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}'});
  final Map<String, dynamic> body = json.decode(response.body);
  final Map<String, dynamic> filtersMap = body['results']['customfielditem_filters'];
  for (Map<String, dynamic> filter in filtersMap.values) {
    CustomFieldItemFilter code = CustomFieldItemFilter.fromJson(filter);
    customFieldItemsFilters.add(code);
  }
  return customFieldItemsFilters;
}

//ANCHOR - SHEETS MANAGER
class SheetsManager extends ChangeNotifier {
  SheetsManager._privateConstructor() {
    SharedPreferences.getInstance().then((tempPrefs) async {
      prefs = tempPrefs;
      serverDataLoading = true;
      loadLocalData();
      await getCurrentTimesheet();
      firstLoad = false;
      notifyListeners();
      await loadServerData();
    });
  }
  static final SheetsManager instance = SheetsManager._privateConstructor();
  SheetsManager();
  late final SharedPreferences prefs;

  bool firstLoad = true;
  bool serverDataLoading = false;

  TextEditingController notesController = TextEditingController();
  TimeSheet? currentSheet;
  DateTime? startTime;
  JobCodes? customer;
  String? billable;
  CustomFieldItem? serviceItem;

  ValueNotifier<int> duration = ValueNotifier(0);
  Timer? durationTimer;

  List<CustomFieldItemFilter> customFieldItemFilters = [];
  List<CustomFields> customFields = [];
  List<Project> projects = [];
  List<JobCodeAssignment> assignments = [];
  List<JobCodes> allJobCodes = [];
  List<CustomFieldItem> serviceItems = [];
  List<TimeSheet> timesheets = [];

  List<JobCodes> get parentJobs {
    List<JobCodes> list = [];
    for (var job in allJobCodes) {
      if (job.parent_id == 0) {
        list.add(job);
      }
    }
    return list;
  }

  List<JobCodes> get assignedJobs {
    List<JobCodes> list = [];
    for (var assignment in assignments) {
      for (var job in allJobCodes) {
        if (assignment.jobcode_id == job.id) {
          list.add(job);
        }
      }
    }
    list.sortBy((element) => element.name);

    return list;
  }

  Future<void> updateSheet() async {
    if (sheetsManager.currentSheet == null) return;
    serverDataLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      'data': [
        {
          'id': currentSheet!.id,
          'jobcode_id': customer?.id.toString(),
          'start': startTime?.toIso8601StringWithTimezone(),
          'notes': notesController.text,
          'customfields': {
            '336090': billable,
            '486514': '',
            '320942': '',
            '1064002': '',
            '320940': serviceItem?.name,
          },
        }
      ],
    };
    Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/timesheets');
    final response = await http.put(
      requestUri,
      headers: {
        "Authorization": "Bearer ${globalUser?.authToken ?? koauthTokenBain}",
        'Content-Type': 'application/json',
        // HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}',
        // HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    serverDataLoading = false;
    notifyListeners();
    _decodeResponse(response.body, false);
  }

  Future<void> clockOut() async {
    if (sheetsManager.currentSheet == null) return;
    Map<String, dynamic> body = {
      'data': [
        {
          'id': sheetsManager.currentSheet!.id,
          'end': DateTime.now().toLocal().toIso8601StringWithTimezone(),
        }
      ],
    };
    TimeSheet tempSheet = sheetsManager.currentSheet!;
    currentSheet = null;
    duration.value = 0;
    durationTimer?.cancel();
    notifyListeners();

    Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/timesheets');
    final response = await http.put(
      requestUri,
      headers: {
        "Authorization": "Bearer ${globalUser?.authToken ?? koauthTokenBain}",
        'Content-Type': 'application/json',
        // HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}',
        // HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    _decodeResponse(response.body, true, tempSheet: tempSheet);
  }

  Future<void> clockIn() async {
    TimeEntry entry = TimeEntry(
      user_id: globalUser!.id,
      jobcode_id: customer!.id.toString(),
      type: 'regular',
      start: startTime?.toLocal().toIso8601StringWithTimezone() ?? DateTime.now().toLocal().toIso8601StringWithTimezone(),
      end: '',
      notes: notesController.text,
      customfields: {
        '336090': billable,
        '486514': '',
        '320942': '',
        '1064002': '',
        '320940': serviceItem?.name,
      },
      attached_files: [],
    );

    currentSheet = TimeSheet(
      user_id: globalUser!.id,
      jobcode_id: customer!.id,
      start: startTime?.toLocal().toIso8601StringWithTimezone() ?? DateTime.now().toLocal().toIso8601StringWithTimezone(),
      end: '',
      notes: notesController.text,
      customfields: {
        '336090': billable,
        '486514': '',
        '320942': '',
        '1064002': '',
        '320940': serviceItem?.name,
      },
    );

    createTimer();
    notifyListeners();

    Map<String, dynamic> body = {
      'data': [entry.toJson()],
    };
    Uri requestUri = Uri.parse('https://rest.tsheets.com/api/v1/timesheets');
    final response = await http.post(
      requestUri,
      headers: {
        "Authorization": "Bearer ${globalUser?.authToken ?? koauthTokenBain}",
        'Content-Type': 'application/json',
        // HttpHeaders.authorizationHeader: 'Bearer ${globalUser?.authToken ?? koauthTokenBain}',
        // HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    _decodeResponse(response.body, false);
    await getCurrentTimesheet();
    _afterCurrentSheetChecked();
    notifyListeners();
  }

  void _decodeResponse(String body, bool isClockOut, {TimeSheet? tempSheet}) {
    int statusCode = 0;
    String statusMessage = '';
    final jsonBody = jsonDecode(body);
    final Map<String, dynamic> responseMap = jsonBody['results']['timesheets'];
    for (Map<String, dynamic> timesheet in responseMap.values) {
      // TimeSheet tsheet = TimeSheet.fromJson(timesheet);
      statusCode = timesheet['_status_code'];
      statusMessage = timesheet['_status_message'];
      statusMessage += '\n${timesheet['_status_extra']}';
      if (statusCode != 200) {
        showQuickPopup(NavigationService.navigatorKey.currentContext!, 'Timesheet Error', statusMessage);
        break;
      }
    }
    if (isClockOut) {
      if (statusCode == 200) {
        currentSheet = null;
        _afterCurrentSheetChecked();
      } else {
        currentSheet = tempSheet;
      }
    }
    serverDataLoading = false;
    notifyListeners();
  }

  void updateNoteController(String newVal) {
    notesController.text = newVal;
  }

  void createTimer() {
    durationTimer?.cancel();
    if (startTime != null) {
      durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentSheet != null) {
          duration.value = DateTime.now().difference(startTime!).inSeconds;
          duration.notifyListeners();
        } else {
          durationTimer?.cancel();
        }
      });
    }
  }

  Future<void> getTimesheets() async {
    timesheets = await getUserTimeSheets();
    notifyListeners();
  }

  Future<void> getCurrentTimesheet() async {
    currentSheet = await getCurrentStatus();
    _afterCurrentSheetChecked();
  }

  Future<void> _getAssignments() async {
    // List<JobCodeAssignment> tempList = [];
    // String listString = prefs.getString('assignments') ?? '';
    // tempList = convertStringToCodableList(listString, JobCodeAssignment.fromJson) ?? [];
    // assignments = tempList;
    assignments = await getJobcodeAssignments();
    // prefs.setString('assignments', convertCodableListToString(projects) ?? '');
  }

  void _getAssignmentsLocal() {
    String listString = prefs.getString('assignments') ?? '';
    assignments = convertStringToCodableList(listString, JobCodeAssignment.fromJson) ?? [];
  }

  Future<void> _getProjects() async {
    List<Project> tempProjects = await getProjects();
    projects.clear();
    for (var project in tempProjects) {
      if (allJobCodes.firstWhereOrNull((element) => element.id == project.jobcode_id) != null) {
        projects.add(project);
      }
    }
    prefs.setString('projects', convertCodableListToString(projects) ?? '');
  }

  void _getProjectsLocal() {
    String listString = prefs.getString('projects') ?? '';
    projects = convertStringToCodableList(listString, Project.fromJson) ?? [];
  }

  Future<void> _getCustomFields() async {
    customFields = await getCustomFields();
    prefs.setString('customFields', convertCodableListToString(customFields) ?? '');
  }

  void _getCustomFieldsLocal() {
    String listString = prefs.getString('customFields') ?? '';
    customFields = convertStringToCodableList(listString, CustomFields.fromJson) ?? [];
  }

  Future<void> _getCustomFieldItemFilters() async {
    customFieldItemFilters = await getCustomFieldItemFilters();
    prefs.setString('customFieldItemFilters', convertCodableListToString(customFieldItemFilters) ?? '');
  }

  void _getCustomFieldItemFiltersLocal() {
    String listString = prefs.getString('customFieldItemFilters') ?? '';
    customFieldItemFilters = convertStringToCodableList(listString, CustomFieldItemFilter.fromJson) ?? [];
  }

  Future<void> getServiceItemForUser() async {
    List<CustomFieldItem> tempList = [];
    String listString = prefs.getString('serviceItems') ?? '';
    tempList = convertStringToCodableList(listString, CustomFieldItem.fromJson) ?? [];
    serviceItems = tempList;
    List<CustomFieldItem> tempServiceList = await getCustomFieldItems(320940);
    serviceItems.clear();
    for (var item in tempServiceList) {
      for (var filter in customFieldItemFilters) {
        if (filter.customfielditem_id == item.id) {
          serviceItems.add(item);
        }
      }
    }
    prefs.setString('serviceItems', convertCodableListToString(serviceItems) ?? '');
  }

  void getServiceItemForUserLocal() {
    String listString = prefs.getString('serviceItems') ?? '';
    serviceItems = convertStringToCodableList(listString, CustomFieldItem.fromJson) ?? [];
  }

  // Future<void> _getAssignedJobCodes() async {
  //   List<JobCodes> tempList = [];
  //   String listString = prefs.getString('assignedJobCodes') ?? '';
  //   tempList = convertStringToCodableList(listString, JobCodes.fromJson) ?? [];
  //   assignedJobCodes = tempList;
  //   List<JobCodes> tempJobCodeList = await getJobcodes();
  //   assignedJobCodes.clear();
  //   assignments = await getJobcodeAssignments();
  //   for (var job in tempJobCodeList) {
  //     for (var assignment in assignments) {
  //       if (job.id == assignment.jobcode_id) {
  //         print(job.name);
  //         assignedJobCodes.add(job);
  //       }
  //     }
  //   }
  //   prefs.setString('assignedJobCodes', convertCodableListToString(assignedJobCodes) ?? '');
  // }

  Future<void> _getAllJobCodes() async {
    allJobCodes = await getJobcodes();
    prefs.setString('allJobCodes', convertCodableListToString(allJobCodes) ?? '');
  }

  void _getAllJobCodesLocal() {
    String listString = prefs.getString('allJobCodes') ?? '';
    allJobCodes = convertStringToCodableList(listString, JobCodes.fromJson) ?? [];
  }

  void _afterCurrentSheetChecked() {
    if (currentSheet != null) {
      customer = allJobCodes.firstWhereOrNull((j) => j.id == currentSheet!.jobcode_id!);
      startTime = DateTime.parse(sheetsManager.currentSheet!.start!).toLocal();
      billable = currentSheet!.billable;
      serviceItem = serviceItems.firstWhereOrNull((element) => element.name == currentSheet!.customfields!['320940']);
      notesController.text = currentSheet!.notes!;
      createTimer();
    } else {
      durationTimer?.cancel();
      duration.value = 0;
      String defaultsString = prefs.getString('jobDefaults') ?? '';
      List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
      if (defaultList.isNotEmpty && sheetsManager.currentSheet == null) {
        int? recentJob = prefs.getInt('jobRecent');
        JobDefaults? x;
        if (recentJob != null) {
          x = defaultList.firstWhereOrNull((element) => element.job?.id == recentJob);
        }
        x ??= defaultList.first;
        customer = x.job;
        billable = x.billable;
        serviceItem = x.serviceItem;
        notesController.text = x.notes ?? '';
      } else {
        customer = null;
        billable = null;
        serviceItem = null;
        notesController.text = '';
      }
    }
    notifyListeners();
  }

  void _getUserLocal() {
    String? user = prefs.getString('user');
    if (user != null) {
      globalUser = convertStringToCodableObject(user, User.fromJson);
    }
  }

  Future<void> loadAllData() async {
    serverDataLoading = true;
    notifyListeners();
    loadLocalData();
    await loadServerData();
  }

  loadLocalData() {
    _getUserLocal();
    _getProjectsLocal();
    _getAllJobCodesLocal();
    _getAssignmentsLocal();
    _getCustomFieldsLocal();
    _getCustomFieldItemFiltersLocal();
    getServiceItemForUserLocal();
    notifyListeners();
  }

  Future<void> loadServerData() async {
    serverDataLoading = true;
    notifyListeners();
    await getUsers();
    await _getProjects();
    await _getAllJobCodes();
    await _getAssignments();
    await _getCustomFields();
    await _getCustomFieldItemFilters();
    await getServiceItemForUser();
    await getTimesheets();
    await getCurrentTimesheet();
    _afterCurrentSheetChecked();
    serverDataLoading = false;
    notifyListeners();
  }
}

DateTime mostRecentWeekday(DateTime date, int weekday) => DateTime(date.year, date.month, date.day - (date.weekday - weekday) % 7);
