import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codable/codable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/app_constants.dart';
import 'package:time/debug_menu.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:time/tsheets_manager.dart';
import 'package:time/widgets/customer_modal.dart';
import 'package:time/widgets/service_item_modal.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _tabController = PlatformTabController();
  SharedPreferences? prefs;
  final sheetsManager = SheetsManager.instance;

  // Time Clock and logging definitions

  // Time Sheet entries defintions
  bool _loadingTimesheets = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((localPrefs) {
      prefs = localPrefs;
      String? user = localPrefs.getString('user');
      if (user != null) {
        globalUser = convertStringToCodableObject(user, User.fromJson);
      }
      String defaultsString = prefs!.getString('jobDefaults') ?? '';
      List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
      if (defaultList.isNotEmpty && sheetsManager.currentSheet == null) {
        int? recentJob = prefs!.getInt('jobRecent');
        JobDefaults? x;
        if (recentJob != null) {
          // print('recent job is not null');
          x = defaultList.firstWhereOrNull((element) => element.job?.id == recentJob);
        }
        x ??= defaultList.first;

        sheetsManager.customer = x.job;
        sheetsManager.billable = x.billable;
        sheetsManager.serviceItem = x.serviceItem;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      // cupertino: (context, platform) => CupertinoTabScaffoldData(resizeToAvoidBottomInset: false),
      iosContentBottomPadding: true,
      iosContentPadding: true,
      tabController: _tabController,
      appBarBuilder: (_, index) => _buildAppBar(index),
      bodyBuilder: (_, index) => _buildBody(index),
      items: _bottomBarItems(),
    );
  }

  PlatformAppBar _buildAppBar(int index) {
    if (index == 0) {
      return PlatformAppBar(
        title: PlatformTextButton(
          padding: EdgeInsets.zero,
          child: const Text('Time Clock'),
          onPressed: () => Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (context) => const DebugMenu(),
              )),
        ),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(PlatformIcons(context).accountCircleSolid),
            onPressed: () {
              showCupertinoModalBottomSheet(context: context, builder: (context) => _userPickerView());
            },
          )
        ],
        leading: _leadingWidget(sheetsManager.serverDataLoading),
      );
    } else {
      return PlatformAppBar(
        title: const Text('Time Entries'),
        leading: _leadingWidget(_loadingTimesheets),
      );
    }
  }

  Widget _leadingWidget(bool input) {
    return Consumer<SheetsManager>(builder: (context, _, __) {
      if (input) {
        return PlatformCircularProgressIndicator();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildBody(int index) {
    if (_tabController.index(context) == 0) {
      return Consumer<SheetsManager>(builder: (context, _, __) {
        if (sheetsManager.firstLoad) {
          return Center(
            child: PlatformCircularProgressIndicator(),
          );
        } else {
          return _clockView();
        }
      });
    } else {
      return Consumer<SheetsManager>(builder: (context, _, __) {
        // sheetsManager.getTimesheets();
        return _entriesView();
      });
    }
  }

  List<BottomNavigationBarItem> _bottomBarItems() {
    return [
      BottomNavigationBarItem(icon: Icon(PlatformIcons(context).clockSolid), label: 'Clock'),
      BottomNavigationBarItem(icon: Icon(PlatformIcons(context).checkMarkCircledOutline), label: 'Entries'),
    ];
  }

  Widget _clockView() {
    if (globalUser == null) {
      return Center(
        child: PlatformElevatedButton(
          onPressed: () {
            showCupertinoModalBottomSheet(context: context, builder: (context) => _userPickerView());
          },
          child: const Text('Select User'),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              _buildDurationCounter(),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                width: 200,
                child: PlatformElevatedButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Text('Start Time: ${DateFormat('jm').format(sheetsManager.startTime ?? DateTime.now())}'),
                  onPressed: () {
                    showPlatformDatePicker(
                        context: context,
                        initialDate: sheetsManager.startTime ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 3)),
                        lastDate: DateTime.now(),
                        cupertino: (context, platform) => CupertinoDatePickerData(
                              mode: CupertinoDatePickerMode.dateAndTime,
                            )).then(
                      (value) => setState(
                        () {
                          if (value != null) {
                            sheetsManager.startTime = value;
                            sheetsManager.updateSheet();
                            sheetsManager.createTimer();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildQuickItemsRow(),
              _customerCell(),
              const SizedBox(
                height: 20,
              ),
              _billableCell(),
              _serviceItemCell(sheetsManager.serviceItem),
              const Spacer(),
              _notesInput(),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: PlatformElevatedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      onPressed: () => _onSwitchJobPressed(),
                      child: const Text('Switch Job'),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: PlatformElevatedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      onPressed: () => _onClockInOut(),
                      color: sheetsManager.currentSheet != null ? Colors.red : Colors.green,
                      child: Text(sheetsManager.currentSheet != null ? 'Clock Out' : 'Clock In'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickItemsRow() {
    String defaultsString = prefs!.getString('jobDefaults') ?? '';
    List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
    if (defaultList.isNotEmpty) {
      List<Widget> children = [];
      for (var job in defaultList) {
        children.add(_buildQuickItemCell(job));
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runAlignment: WrapAlignment.center,
          runSpacing: 10,
          children: children,
        ),
      );
    } else {
      return const Spacer();
    }
  }

  Widget _buildQuickItemCell(JobDefaults job) {
    String parentNames = '';

    JobCodes? parentJob = _getParentJob(job.job?.id);
    JobCodes? parentParentJob;

    if (parentJob != null) parentParentJob = _getJob(parentJob.parent_id);

    if (parentJob != null) {
      parentNames = parentJob.name;
      if (parentParentJob != null) {
        parentNames = '${parentParentJob.name} > ${parentJob.name}';
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      width: 200,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.job?.name ?? 'No Customer',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              parentNames,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            Text(
              job.serviceItem?.name ?? 'No Service Item',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            Text(
              job.billable != null ? 'Billable' : '',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            Text(
              job.notes ?? 'No Notes',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSwitchJobPressed() async {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => CustomerModal(
        prefs: prefs!,
        callback: (int id) async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          await sheetsManager.clockOut();
          setState(() {
            sheetsManager.customer = sheetsManager.allJobCodes.firstWhereOrNull((element) => element.id == id);
            sheetsManager.startTime = DateTime.now();
            _loadJobDefaults(sheetsManager.customer);
          });
          await sheetsManager.clockIn();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildDurationCounter() {
    return ValueListenableBuilder(
      valueListenable: sheetsManager.duration,
      builder: (context, value, _) {
        if (value > 0) {
          return Text(
            _formatDuration(value, showSeconds: true),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
          );
        } else {
          return const Text(
            'Clocked Out',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
          );
        }
      },
    );
  }

  void _onClockInOut() {
    if (sheetsManager.currentSheet != null) {
      if (sheetsManager.customer == null) {
        showQuickPopup(context, 'Unable', 'Customer is not selected');
      } else if (sheetsManager.billable == null) {
        showQuickPopup(context, 'Unable', 'Billable is not selected');
      } else if (sheetsManager.serviceItem == null) {
        showQuickPopup(context, 'Unable', 'Service Item');
      } else if (sheetsManager.notesController.text.isEmpty) {
        showQuickPopup(context, 'Unable', 'Notes is empty');
      } else {
        sheetsManager.clockOut();
      }
    } else {
      if (sheetsManager.customer == null) {
        showQuickPopup(context, 'Unable', 'Customer is not selected');
      } else if (sheetsManager.billable == null) {
        showQuickPopup(context, 'Unable', 'Billable is not selected');
      } else if (sheetsManager.serviceItem == null) {
        showQuickPopup(context, 'Unable', 'Service Item');
      } else {
        sheetsManager.startTime ??= DateTime.now();
        sheetsManager.clockIn();
        _saveJobDefaults();
      }
    }
  }

  Widget _notesInput() {
    return PlatformListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: 150,
            child: PlatformTextField(
              maxLines: 5,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              controller: sheetsManager.notesController,
              onEditingComplete: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (sheetsManager.currentSheet != null) {
                  sheetsManager.updateSheet();
                }
                _saveJobDefaults();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceItemCell(CustomFieldItem? serviceItem) {
    return PlatformListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Item',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          Text(
            serviceItem?.name ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Icon(PlatformIcons(context).rightChevron),
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (_) => ServiceItemModal(
            callback: (CustomFieldItem item) {
              setState(() {
                sheetsManager.serviceItem = item;
                sheetsManager.updateSheet();
                Navigator.pop(context);
              });
              _saveJobDefaults();
            },
          ),
        );
      },
    );
  }

  Widget _billableCell() {
    return PlatformListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billable',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            Text(
              sheetsManager.billable ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PlatformSwitch(
          value: sheetsManager.billable == 'Yes',
          onChanged: (newVal) => _changeBillable(),
        ),
        onTap: () => _changeBillable());
  }

  void _changeBillable() {
    setState(() {
      if (sheetsManager.billable == 'Yes') {
        sheetsManager.billable = 'No';
      } else {
        sheetsManager.billable = 'Yes';
      }
    });
    _saveJobDefaults();
    if (sheetsManager.currentSheet != null) {
      sheetsManager.updateSheet();
    }
  }

  Widget _customerCell() {
    JobCodes? parentJob = _getParentJob(sheetsManager.customer?.id);
    JobCodes? parentParentJob;

    if (parentJob != null) parentParentJob = _getJob(parentJob.parent_id);

    String parentNames = '';

    if (parentJob != null) {
      parentNames = parentJob.name;
      if (parentParentJob != null) {
        parentNames = '${parentParentJob.name} > ${parentJob.name}';
      }
    }
    return PlatformListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          Text(
            sheetsManager.customer?.name ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            parentNames,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Icon(PlatformIcons(context).rightChevron),
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => CustomerModal(
            prefs: prefs!,
            callback: (int id) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              setState(() {
                sheetsManager.customer = sheetsManager.allJobCodes.firstWhereOrNull((element) => element.id == id);
                _loadJobDefaults(sheetsManager.customer);
                sheetsManager.updateSheet();
              });
            },
          ),
        );
      },
    );
  }

  Widget _entriesView() {
    if (globalUser == null) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          'No user chosen. Navigate to "Users" page and choose a user.',
          textAlign: TextAlign.center,
        ),
      ));
    }
    if (sheetsManager.timesheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No Timesheets available for this week.'),
            ),
            SizedBox(
              width: 250,
              child: PlatformElevatedButton(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                onPressed: () async {
                  setState(() {
                    _loadingTimesheets = true;
                  });
                  final tempSheets = await getUserTimeSheets();
                  sheetsManager.timesheets.clear();
                  setState(() {
                    sheetsManager.timesheets = tempSheets;
                    _loadingTimesheets = false;
                  });
                },
                child: Stack(
                  children: [
                    const Align(alignment: Alignment.center, child: Text('Refresh Timesheets')),
                    _loadingTimesheets
                        ? Positioned(
                            right: 10,
                            child: PlatformCircularProgressIndicator(
                              cupertino: (context, platform) => CupertinoProgressIndicatorData(color: Colors.white),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            setState(() {
              _loadingTimesheets = true;
            });
            final tempSheets = await getUserTimeSheets();
            sheetsManager.timesheets.clear();
            setState(() {
              sheetsManager.timesheets = tempSheets;
              _loadingTimesheets = false;
            });
          },
          child: GroupedListView(
            elements: sheetsManager.timesheets,
            groupBy: (TimeSheet e) => e.date!,
            groupSeparatorBuilder: (String value) => _timesheetSeparator(value),
            indexedItemBuilder: (context, element, index) => _timesheetTile(element),
            order: GroupedListOrder.DESC,
          ),
        ),
      );
    }
  }

  Widget _timesheetSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.shade200),
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(DateTime.parse(date)),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      DateFormat('MMM d').format(DateTime.parse(date)),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: sheetsManager.duration,
                      builder: (context, value, _) {
                        int totalDuration = 0;
                        for (TimeSheet sheet in sheetsManager.timesheets) {
                          if (sheet.date == date) {
                            totalDuration += sheet.duration!;
                          }
                        }
                        if (sheetsManager.currentSheet?.date != null && sheetsManager.currentSheet!.date! == date) {
                          totalDuration += value;
                        }
                        return Text(
                          _formatDuration(totalDuration),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        );
                      },
                    ),
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timesheetTile(TimeSheet sheet) {
    JobCodes? job = _getJob(sheet.jobcode_id!);
    // JobCodes? parentJob = _getParentJob(sheet.jobcode_id!);
    // JobCodes? parentParentJob;

    // if (parentJob != null) parentParentJob = _getJob(parentJob.parent_id);

    // String parentNames = '';

    // if (parentJob != null) {
    //   parentNames = parentJob.name;
    //   if (parentParentJob != null) {
    //     parentNames = '${parentParentJob.name} > ${parentJob.name}';
    //   }
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          PlatformListTile(
            trailing: Text(
              _formatDuration(sheet.duration!),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            title: AutoSizeText(
              job?.name ?? 'N/A',
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   parentNames,
                // ),
                Text('BILLABLE: ${sheet.billable}'),
                Text('NOTES: ${sheet.notes ?? ''}'),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _userPickerView() {
    String usersString = prefs?.getString('users') ?? '';
    List<User> users = convertStringToCodableList(usersString, User.fromJson) ?? [];
    getUsers().then((newUsers) {
      setState(() {
        users = newUsers;
      });
    });
    return Center(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _userListTile(users[index]);
        },
        itemCount: users.length,
      ),
    );
  }

  Widget _userListTile(User user) {
    bool selected = false;
    if (globalUser?.display_name == user.display_name) selected = true;
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        PlatformListTile(
          title: Text(user.display_name ?? 'N/A'),
          trailing: selected ? Icon(PlatformIcons(context).checkMarkCircled) : null,
          onTap: () async {
            globalUser = user;
            String? codableUser = convertCodableObjectToString(globalUser);
            if (codableUser != null) {
              prefs!.setString('user', codableUser);
            }
            setState(() {
              sheetsManager.duration.value = 0;
              sheetsManager.durationTimer?.cancel();
              sheetsManager.currentSheet = null;
            });
            Navigator.pop(context);
            await sheetsManager.getCurrentTimesheet();
            await sheetsManager.getTimesheets();
            await sheetsManager.loadAllData();
          },
        ),
      ],
    );
  }

  JobCodes? _getJob(int jobcodeId) {
    return sheetsManager.allJobCodes.firstWhereOrNull((e) => e.id == jobcodeId);
  }

  JobCodes? _getParentJob(int? jobcodeId) {
    if (jobcodeId == null) return null;
    JobCodes? job = sheetsManager.allJobCodes.firstWhereOrNull((e) => e.id == jobcodeId);
    JobCodes? parentJob = sheetsManager.allJobCodes.firstWhereOrNull((e) => e.id == job?.parent_id);
    return parentJob;
  }

  void _loadJobDefaults(JobCodes? job) {
    String defaultsString = prefs!.getString('jobDefaults') ?? '';
    List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
    JobDefaults? x = defaultList.firstWhereOrNull((element) => element.job?.id == job?.id);
    if (x != null) {
      sheetsManager.billable = x.billable;
      sheetsManager.serviceItem = x.serviceItem;
    }
  }

  void _saveJobDefaults() {
    JobDefaults defaults = JobDefaults(
      sheetsManager.customer,
      sheetsManager.allJobCodes.firstWhereOrNull((j) => j.id == sheetsManager.customer?.parent_id),
      sheetsManager.billable,
      sheetsManager.serviceItem,
      sheetsManager.notesController.text,
    );
    String defaultsString = prefs!.getString('jobDefaults') ?? '';
    List<JobDefaults> defaultList = convertStringToCodableList(defaultsString, JobDefaults.fromJson) ?? [];
    int x = defaultList.indexWhere((element) => element.job?.id == defaults.job?.id);
    if (x != -1) {
      defaultList.removeAt(x);
    }
    defaultList.add(defaults);
    prefs!.setString('jobDefaults', convertCodableListToString(defaultList) ?? '');
    prefs!.setInt('jobRecent', defaults.job?.id ?? 0);
    setState(() {});
  }
}

String _formatDuration(int seconds, {bool showSeconds = false}) {
  // Calculate hours, minutes and seconds
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  if (showSeconds) {
    if (hours > 0) {
      return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '$remainingSeconds sec';
    }
  } else {
    if (hours > 0) {
      return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return '$minutes min';
    }
  }
}

// DateTime _roundToMinute(DateTime dateTime) {
//   dateTime = dateTime.add(const Duration(seconds: 30));
//   return (dateTime.isUtc ? DateTime.utc : DateTime.new)(
//     dateTime.year,
//     dateTime.month,
//     dateTime.day,
//     dateTime.hour,
//     dateTime.minute,
//   );
// }
