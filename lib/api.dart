import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:developer' as developer;

Future<http.Response> fetchFontListGoogle() {
  return http.get(Uri.parse('https://fonts.google.com/metadata/fonts'));
}