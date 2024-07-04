import 'package:flutter/material.dart';
import 'dart:async';

class Volunteership extends StatefulWidget {
  const Volunteership({super.key});

  @override
  State<Volunteership> createState() => _VolunteershipState();
}

class _VolunteershipState extends State<Volunteership> {
  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Add a new item at the beginning of the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/Logo.png',
                      height: 50,
                      fit: BoxFit.fitHeight,
                    ),
                    const Text(
                      'Enrolled \n Opportunities',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Logic for filtering volunteer cards
                      },
                      child: const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const SafeArea(
        child: const Text(
          'Enrolled Opportunities',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
