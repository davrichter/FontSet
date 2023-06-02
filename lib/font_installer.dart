import 'dart:io';

void installFonts(Map<String, dynamic> fontUrls, String family) async {
  fontUrls.forEach((key, value) async {
    final request = await HttpClient().getUrl(Uri.parse(value));
    final response = await request.close();
    response.pipe(File("${family}-${key}.ttf").openWrite());
  });
}