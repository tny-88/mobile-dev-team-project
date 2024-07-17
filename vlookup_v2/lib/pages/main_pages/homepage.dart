import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vlookup_v2/models/event_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/provider/user_provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

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
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

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


  void addEventToCalendar() {
    final Event event = Event(
      title: titleController.text,
      description: descriptionController.text.isNotEmpty
          ? descriptionController.text
          : '',
      location:
          locationController.text.isNotEmpty ? locationController.text : '',
      startDate: _selectedDateTime!,
      endDate: _selectedDateTime!
          .add(const Duration(hours: 2)), // Assume events last 2 hours
    );

    Add2Calendar.addEvent2Cal(event);
  }




  Future<void> _createEvent() async {
    var uuid = Uuid();
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
      }),
    );

    if (response.statusCode == 200) {
      _promptForImageUpload(eventId);
      _resetFormFields();
      _fetchEvents();
    } else {
      _showAlert(
          'Failed to Create Event', 'Something went wrong. Please try again.');
    }
  }

  void _promptForImageUpload(String eventId) async {
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
                onTap: () => _getImage(ImageSource.camera, eventId),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () => _getImage(ImageSource.gallery, eventId),
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Skip Image Upload'),
                onTap: () {
                  Navigator.pop(context); // Close the modal bottom sheet
                  addEventToCalendar(); // Add event to calendar without uploading image
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source, String eventId) async {
    Navigator.pop(context); // Close the modal bottom sheet
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
        addEventToCalendar(); // Add to calendar after successful image upload
      } else {
        _showAlert('Upload Failed', 'Failed to upload image.');
      }
    } else {
      addEventToCalendar(); // Add to calendar directly if no image is uploaded
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.description),
                      onTap: () {
                        // Add navigation or other interaction
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
