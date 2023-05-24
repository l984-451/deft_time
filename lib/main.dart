import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:time/home.dart';
import 'package:time/tsheets_manager.dart';

void main() {
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SheetsManager>(
          create: (context) => SheetsManager.instance,
        )
      ],
      child: PlatformProvider(
        settings: PlatformSettingsData(iosUseZeroPaddingForAppbarPlatformIcon: true),
        builder: (context) => PlatformApp(
          navigatorKey: NavigationService.navigatorKey,
          cupertino: (context, platform) => CupertinoAppData(),
          home: const Home(),
        ),
      ),
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
