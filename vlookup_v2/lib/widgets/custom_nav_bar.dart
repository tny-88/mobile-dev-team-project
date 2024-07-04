import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/pages/main_pages/homepage.dart';
import 'package:vlookup_v2/pages/main_pages/profile.dart';
import 'package:vlookup_v2/pages/main_pages/volunteership.dart';
import 'package:vlookup_v2/provider/user_provider.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final List<Widget> _widgetOptions = [
      const HomePage(),
      const Volunteership(),
      const Profile(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Volunteership'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}