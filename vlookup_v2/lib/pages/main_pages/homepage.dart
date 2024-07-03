import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _items = List.generate(
    5,
    (index) => {
      "id": index,
      "title": "Title ${index + 1}",
      "description": "Description ${index + 1}",
      "image": "assets/images/image_${index + 1}.jpg",
    },
  );

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

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
                  _image != null
                      ? Image.file(
                          _image!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50),
                        ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.camera),
                        child: Text('Take Photo'),
                      ),
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.gallery),
                        child: Text('Choose from Gallery'),
                      ),
                    ],
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
        preferredSize: const Size.fromHeight(150.0), // height of appbar
        child: AppBar(
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  height: 90,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(height: 10),
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        onPressed: _showForm,
        child: Icon(Icons.add),
      ),
    );
  }
}
