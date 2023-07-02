import 'dart:io' show Platform;

import 'package:win_toast/win_toast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void sendNotification(String message) {
  if (Platform.isWindows) {
    WinToast.instance().initialize(
      aumId: '21738DavidRichter.FontSet',
      displayName: 'FontSet',
      iconPath: '',
      clsid: 'A2232234-1234-1234-1234-123412341234',
    );

    var xml = """
      <toast launch='conversationId=9813'>
          <visual>
              <binding template='ToastGeneric'>
                  <text>$message</text>
              </binding>
          </visual>
      </toast>

      """;
    WinToast.instance().showCustomToast(xml: xml);
  }

  if (Platform.isLinux || Platform.isMacOS) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
            linux: initializationSettingsLinux,
            macOS: initializationSettingsMacOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    flutterLocalNotificationsPlugin.show(
      123,
      'FontSet',
      message,
      null,
    );
  }
}
