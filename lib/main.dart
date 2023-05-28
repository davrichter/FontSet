import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
 import 'package:provider/provider.dart'; 

import 'api.dart';

Future<Fonts> fetchFonts() async {
  final response = await http
      .get(Uri.parse('https://www.googleapis.com/webfonts/v1/webfonts?key=AIzaSyC4-RJRczfKwo-7fMFdOoRBpIDKxDBlNns'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final fonts = Fonts.fromJson(jsonDecode(response.body));
    developer.log(fonts.items[0].lastModified.year.toString(), name: 'my.app.category');
    return fonts;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

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
        }
    );
  }
}

class MyAppState extends ChangeNotifier {
  var appTheme = Brightness.light;

  void setTheme(Brightness brightness) {
    appTheme = brightness;

    notifyListeners();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
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
            ]
          ),
        );
      }
    );
  }
}

class FontPage extends StatelessWidget {
  Future<Fonts>? fonts = fetchFonts();

  @override
  Widget build(BuildContext context) {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: (
          Padding(
            padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
            child: FutureBuilder<Fonts>(
            future: fonts, 
            builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                children: snapshot.data!.items.map((font) => FontCard(font: font)).toList()
              );
            } 
            return const CircularProgressIndicator();
          })),
          )
        ),
      )
    ],
  );
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
          )
        )
      ],
    );
  }
}

class FontCard extends StatelessWidget {
  const FontCard({Key? key, required this.font}) : super(key: key);

  final Item font;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
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
            )
          ],
        ),
      ),
    );
  }
}
