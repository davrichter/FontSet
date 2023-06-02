import 'dart:io' show Platform;

import 'package:win_toast/win_toast.dart';

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
}
