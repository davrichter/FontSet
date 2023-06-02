import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:dotenv/dotenv.dart';

import 'api.dart';
import 'font_installer.dart';
import 'notification_sender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAppState>(
        create: (_) => MyAppState(),
        builder: (context, child) {
          // No longer throws
          return MaterialApp(
            title: 'Namer App',
            theme: ThemeData(
              useMaterial3: true,
              brightness: context.watch<MyAppState>().appTheme,
            ),
            home: MyHomePage(),
          );
        });
  }
}

class MyAppState extends ChangeNotifier {
  var appTheme = Brightness.light;
  List<Item> filteredFonts = [];
  List<Item> unfilteredFonts = [];
  String fontPreviewText = 'The quick brown fox jumps over the lazy dog';

  void setTheme(Brightness brightness) {
    appTheme = brightness;

    notifyListeners();
  }

  void setFilteredFonts(List<Item> fonts) {
    filteredFonts = fonts;

    notifyListeners();
  }

  void setFonts(List<Item> fonts) {
    unfilteredFonts = fonts;

    notifyListeners();
  }

  void setFontPreviewText(String text) {
    fontPreviewText = text;

    notifyListeners();
  }
}

Future<Fonts> fetchFonts() async {
  var env = DotEnv(includePlatformEnvironment: false)..load([".env"]);
  var googleFontsKey = env['GOOGLE_FONTS_KEY'];
  final response = await http.get(Uri.parse(
      'https://www.googleapis.com/webfonts/v1/webfonts?key=$googleFontsKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final fonts = Fonts.fromJson(jsonDecode(response.body));

    return fonts;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = FontPage();
        break;
      case 1:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(children: [
          SafeArea(
            child: NavigationRail(
              extended: constraints.maxWidth >= 600,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home),
                  label: Text('Home', style: theme.textTheme.bodyMedium),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings),
                  label: Text('Settings', style: theme.textTheme.bodyMedium),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: theme.colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ]),
      );
    });
  }
}

class FontPage extends StatefulWidget {
  @override
  State<FontPage> createState() => _FontPageState();
}

class _FontPageState extends State<FontPage> {
  TextEditingController textController = TextEditingController();
  String displayText = "";
  Fonts? fonts;

  @override
  void initState() {
    var appState = Provider.of<MyAppState>(context, listen: false);

    fetchFonts().then((value) => {
          appState.setFonts(value.items),
          appState.setFilteredFonts(value.items),
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term',
                  ),
                  onChanged: (value) async => {
                    appState.setFilteredFonts(
                        fontFilter(value, appState.unfilteredFonts)),
                  },
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'The quick brown fox jumps over the lazy dog',
                ),
                onChanged: (value) async => {
                  appState.setFontPreviewText(value),
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: (Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: appState.filteredFonts
                      .map((font) => FontCard(font: font))
                      .toList()))),
        )
      ],
    );
  }
}

List<Item> fontFilter(String enteredKeyword, List<Item> fonts) {
  if (enteredKeyword.isEmpty) {
    // if the search field is empty or only contains white-space, we'll display all fonts
    return fonts;
  } else {
    final results = fonts
        .where((font) =>
            font.family.toLowerCase().contains(enteredKeyword.toLowerCase()))
        .toList();
    return results;
    // we use the toLowerCase() method to make it case-insensitive
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.displayMedium,
                ),
                const Divider(
                  color: Colors.black,
                ),
                Row(children: [
                  Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (appState.appTheme == Brightness.light) {
                        appState.setTheme(Brightness.dark);
                      } else {
                        appState.setTheme(Brightness.light);
                      }
                    },
                    child: Text(
                      'Switch',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ]),
              ],
            ))
      ],
    );
  }
}

class FontCard extends StatelessWidget {
  const FontCard({Key? key, required this.font}) : super(key: key);

  final Item font;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(font.family),
                      Text(font.category),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${font.variants.length.toString()} variants"),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: _buildFontText(appState),
                ),
                ElevatedButton(
                  style: const ButtonStyle(),
                  onPressed: () {
                    installFonts(font.files, font.family);
                    developer.log("${font.family} has been installed");
                    sendNotification("${font.family} has been installed");
                  },
                  child: const Text('Install'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontText(MyAppState appState) {
    try {
      return Text(appState.fontPreviewText,
          style: GoogleFonts.getFont(font.family, fontSize: 20));
    } catch (e) {
      return const Text("Error loading font");
    }
  }
}
