import 'package:flutter/material.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> _items = List.generate(
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

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Implement image picking functionality
                    },
                    child: Text('Upload Image'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement location upload functionality
                    },
                    child: Text('Upload Location'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement form submission
                      Navigator.pop(context);
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // height of appbar
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/Logo.png',
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          centerTitle: true,
          actions: [
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Image.asset(_items[index]['image']),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _items[index]['title'],
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                _items[index]['description'],
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        onPressed: _showForm,
        child: Icon(Icons.add),
      ),
    );
  }
}
