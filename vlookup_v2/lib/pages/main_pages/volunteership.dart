import 'package:flutter/material.dart';
import 'dart:async';

class Volunteership extends StatefulWidget {
  const Volunteership({super.key});

  @override
  State<Volunteership> createState() => _VolunteershipState();
}

class _VolunteershipState extends State<Volunteership> {
  final List<Map<String, dynamic>> _items = List.generate(
    5,
    (index) => {
      "id": index,
      "title": "Title ${index + 1}",
      "description": "Description ${index + 1}",
      "image": "assets/images/image_${index + 1}.jpg",
    },
  );

  Future<void> _refreshData() async {
    // Simulating a network request
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Add a new item at the beginning of the list
      _items.insert(0, {
        "id": _items.length,
        "title": "New Title ${_items.length + 1}",
        "description": "New Description ${_items.length + 1}",
        "image": "assets/images/image_1.jpg", // You might want to change this
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: AppBar(
          backgroundColor: Colors.white,
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
                Text(
                  'Enrolled Opportunities',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(_items[index]['image']),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                _items[index]['title'],
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                _items[index]['description'],
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ]));
            },
          ),
        ),
      ),
    );
  }
}
