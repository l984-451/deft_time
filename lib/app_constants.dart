import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/tsheets_data_models.dart';

const String koauthTokenBain = 'S.12__4658de57a08268b43ff73b18159df14beff4de96';
const String koauthTokenAustin = 'S.12__3f9af04acfaa7681e4291fd8fd1b411c3ba6574e';
const String koauthTokenKyle = 'S.12__b957dc0721d3b754ad40c772b4be7bc508536a25';
const String koauthTokenAndrew = 'S.12__d35dccf603a2f68b0f00c83f4484382b55ce1074';
const String koauthTokenLisa = 'S.12__0b996060e2b8f8281b07bf98f4c56fa6bfeadbd8';
const String koauthTokenJosh = 'S.12__cfaaf4796699caeda9b382279a54ff4d17bcb531';
const String koauthTokenJonathan = 'S.12__5a5433266b5adbe831af841e742830c557b6c82d ';

String authToken = '';

SharedPreferences? prefs;
User? globalUser;

extension DateTimeIso8601 on DateTime {
  String toIso8601StringWithTimezone() {
    final duration = timeZoneOffset;
    final difference = duration.isNegative ? '-' : '+';
    final hours = duration.abs().inHours.toString().padLeft(2, '0');
    final minutes = (duration.abs().inMinutes % 60).toString().padLeft(2, '0');
    return '${toIso8601String().split('.').first}$difference$hours:$minutes';
  }
}

void showQuickPopup(BuildContext context, String title, String message) {
  showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        message,
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        )
      ],
    ),
  );
}

void showLoadingIndicator(BuildContext context, String? text) {
  showPlatformDialog(
    barrierDismissible: false,
    context: context,
    builder: (popupContext) => Center(
      child: Container(
        width: text == null ? 75 : 100,
        height: text == null ? 75 : 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: CupertinoColors.lightBackgroundGray,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text != null
                  ? AutoSizeText(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                width: 50,
                height: 50,
                child: PlatformCircularProgressIndicator(
                  material: (_, __) => MaterialProgressIndicatorData(color: Colors.black),
                  cupertino: (_, __) => CupertinoProgressIndicatorData(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
