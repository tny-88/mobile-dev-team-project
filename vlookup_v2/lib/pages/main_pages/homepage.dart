import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vlookup_v2/models/event_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/provider/user_provider.dart';
import 'package:vlookup_v2/pages/main_pages/events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AppEvent> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

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
              .map((data) => AppEvent.fromJson(data as Map<String, dynamic>))
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

  DateTime? _selectedDateTime;

  Future<void> pickDateTime(
      BuildContext context, StateSetter setModalState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setModalState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text =
              DateFormat('dd MM yyyy HH:mm').format(_selectedDateTime!);
        });
      }
    }
  }

  Future<void> _createEvent() async {
    // Ensure all required fields are filled before creating an event
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        dateTimeController.text.isEmpty ||
        locationController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showAlert('Missing Information', 'Please fill out all fields.');
      return;
    }

    var uuid = const Uuid();
    String eventId = uuid.v4();
    String userEmail =
        Provider.of<UserProvider>(context, listen: false).user?.email ?? "";

    var response = await http.post(
      Uri.parse('https://vlookup-api.ew.r.appspot.com/create_event'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'event_id': eventId,
        'title': titleController.text,
        'description': descriptionController.text,
        'date': dateTimeController.text,
        'location': locationController.text,
        'email': userEmail,
        'phone_number': phoneController.text,
        'image': 'assets/images/default_event_image.jpg', // Default image path
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(
          context); // Dismiss the bottom sheet right after successful creation
      _promptForImageUpload(eventId); // Then prompt for image upload
      _resetFormFields(); // Reset the form fields for next use
      _fetchEvents(); // Refresh the list of events
    } else {
      _showAlert(
          'Failed to Create Event', 'Something went wrong. Please try again.');
    }
  }

  void _promptForImageUpload(String eventId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  _getImage(ImageSource.camera, eventId);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  _getImage(ImageSource.gallery, eventId);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Skip Image Upload'),
                onTap: () {
                  Navigator.pop(
                      context); // Close the menu without uploading an image
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source, String eventId) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      var uri = Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/upload_event_pic/$eventId');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        _showAlert('Image Uploaded', 'The image was successfully uploaded.');
      } else {
        _showAlert('Upload Failed', 'Failed to upload image.');
      }
    } else {
      _showAlert('Image Upload Canceled', 'No image was selected.');
    }
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines:
                            5, // Set this to a higher number for more lines
                      ),
                      TextField(
                        controller: dateTimeController,
                        decoration: InputDecoration(labelText: 'Date and Time'),
                        onTap: () => pickDateTime(context, setModalState),
                      ),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(labelText: 'Location'),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone'),
                      ),
                      ElevatedButton(
                        onPressed: _createEvent,
                        child: Text('Create Event'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _resetFormFields() {
    titleController.clear();
    descriptionController.clear();
    dateTimeController.clear();
    locationController.clear();
    phoneController.clear();
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateTimeController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome ${user?.name ?? ''}\n',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: 'Browse the available events',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    const Spacer(),
                    Image.asset(
                      'assets/images/Logo.png',
                      height: 60,
                      fit: BoxFit.fitHeight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsPage(event: event),
                              ),
                            );
                          },
                          child: HomepageCard(
                            imagePath: event.image,
                            title: event.title,
                            description: event.description,
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//This class is meant to hold the data for the each location and to be used and create a card for them
class HomepageCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const HomepageCard({
    required this.imagePath,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          imagePath.startsWith('assets/')
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                )
              : Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
