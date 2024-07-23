import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/pages/main_pages/LogInPage.dart';
import 'package:vlookup_v2/pages/main_pages/SignUpPage.dart';
import 'package:vlookup_v2/pages/main_pages/SplashOptionsPage.dart';
import 'package:vlookup_v2/widgets/custom_nav_bar.dart';
import 'package:vlookup_v2/provider/user_provider.dart';

void main() async {
  await Future.delayed(const Duration(seconds: 4));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'VlookUp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
        ),
        initialRoute: '/', // Initial route is usually the splash or login page
        routes: {
          '/': (context) => const SplashOptions(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const CustomNavBar(), // Directs here post-login
        },
      ),
    );
  }
}
