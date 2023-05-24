import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:time/tsheets_data_models.dart';
import 'package:time/tsheets_manager.dart';

class ServiceItemModal extends StatefulWidget {
  final Function callback;
  const ServiceItemModal({Key? key, required this.callback}) : super(key: key);

  @override
  State<ServiceItemModal> createState() => _ServiceItemModalState();
}

class _ServiceItemModalState extends State<ServiceItemModal> {
  final sheetsManager = SheetsManager.instance;
  @override
  void initState() {
    super.initState();
    if (sheetsManager.serviceItems.isEmpty) {
      // print('getting new items');
      sheetsManager.getServiceItemForUser().then((_) => setState(() {
            // print(sheetsManager.serviceItems.length);
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemBackground,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _buildListTile(sheetsManager.serviceItems[index]);
        },
        itemCount: sheetsManager.serviceItems.length,
      ),
    );
  }

  Widget _buildListTile(CustomFieldItem item) {
    return PlatformListTile(
      title: Text(
        item.name.replaceAll('TS:', ''),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      onTap: () => widget.callback(item),
    );
  }
}
