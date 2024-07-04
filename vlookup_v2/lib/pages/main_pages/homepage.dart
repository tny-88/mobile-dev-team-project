import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vlookup_v2/models/event_model.dart';
import 'package:vlookup_v2/pages/main_pages/events_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  //Function that fetches events from the API
  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('https://vlookup-api.ew.r.appspot.com/get_events'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _events = jsonResponse
              .map((data) => Event.fromJson(data as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load events.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching events: $e';
      });
    }
  }

  //Function that allows user to take a photo or choose from gallery
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  //Function that clears any image the user has taken when the form is closed
  void resetImage() {
    setState(() {
      _image = null; // Reset the image when the form is closed
    });
  }

  //Function that brings up form for user to add a new event
  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
            onWillPop: () async {
              resetImage();
              return true;
            },
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setModalState) {
                      return Column(
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
                                onPressed: () async {
                                  final XFile? pickedImage = await _picker
                                      .pickImage(source: ImageSource.camera);
                                  if (pickedImage != null) {
                                    setModalState(() {
                                      _image = File(pickedImage.path);
                                    });
                                  }
                                },
                                child: const Text('Take Photo'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final XFile? pickedImage = await _picker
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    setModalState(() {
                                      _image = File(pickedImage.path);
                                    });
                                  }
                                },
                                child: const Text('Choose from Gallery'),
                              ),
                            ],
                          ),
                          const TextField(
                            decoration: InputDecoration(labelText: 'Title'),
                          ),
                          const TextField(
                            decoration:
                                InputDecoration(labelText: 'Description'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              //upload functionality
                            },
                            child: const Text('Upload Location'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement form submission
                              Navigator.pop(context);
                              resetImage();
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ));
      },
    );
  }

  //Function that creates and navigates to the volunteer details page
  void _navigateToDetailPage(event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_errorMessage, textAlign: TextAlign.center),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchEvents,
                    child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return GestureDetector(
                          onTap: () => _navigateToDetailPage(event),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                ListTile(
                                  title: Text(event.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(event.description,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
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
        ));
  }
}
