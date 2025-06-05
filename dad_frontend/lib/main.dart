import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'joke_provider.dart';
import 'joke_screen.dart';
import 'gallary_screen.dart';

void main() {
  runApp( 
    MultiProvider(
      providers:[
        ChangeNotifierProvider(
        create: (_) => JokeProvider(),
        ), 
        ChangeNotifierProvider(
          create: (_) => JokesGallaryProvider(),
        )
      ],
      child: MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => JokeScreen(),
        '/gallary': (context) => GallaryScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 204, 0),
          secondary: const Color.fromARGB(255, 76, 43, 6),
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 255, 204, 0),
          titleTextStyle: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 76, 43, 6)),
        ),
      ),
    );
  }
}
