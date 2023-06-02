import 'dart:io' show Platform;

import 'package:win_toast/win_toast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void sendNotification(String message) {
  if (Platform.isWindows) {
    WinToast.instance().initialize(
      aumId: 'one.mixin.FontSet',
      displayName: 'FontSet',
      iconPath: '',
      clsid: 'your-notification-activator-guid-2EB1AE5198B7',
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
