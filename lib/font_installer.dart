import 'dart:io';

import 'package:flutter/services.dart';

Future<void> installFonts(Map<String, dynamic> fontUrls, String family) async {
  const platform = MethodChannel('font_installer.fontset.dev/install_font');

  Future<void> installFont(String fontPath) async {
    try {
      int numberOfFontsInstalled =
      await platform.invokeMethod('installFont', {"fontPath": fontPath});

      // The windows function returns 0 if the installation failed
      if (numberOfFontsInstalled == 0) {
        throw Exception("Installing font failed. 0 fonts were installed");
      }
    } on PlatformException catch (e) {
      throw Exception("Installing font failed: $e");
    }
  }

  for (MapEntry fontUrl in fontUrls.entries) {
    final fontPath = "$family-${fontUrl.key}.ttf";

    final request = await HttpClient().getUrl(Uri.parse(fontUrl.value));
    final response = await request.close();
    final file = File(fontPath);
    await response.pipe(file.openWrite());
    await installFont(fontPath);
    file.delete();
  }
}
