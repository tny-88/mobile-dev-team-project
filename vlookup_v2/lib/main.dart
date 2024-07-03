import 'package:flutter/material.dart';
import 'package:vlookup_v2/pages/main_pages/LogInPage.dart';
import 'package:vlookup_v2/pages/main_pages/SignUpPage.dart';
import 'package:vlookup_v2/pages/main_pages/Splash.dart';
import 'package:vlookup_v2/widgets/custom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VlookUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const CustomNavBar(),
      },
    );
  }
}
