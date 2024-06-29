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
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
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
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        child: Icon(Icons.add),
      ),
    );
  }
}
