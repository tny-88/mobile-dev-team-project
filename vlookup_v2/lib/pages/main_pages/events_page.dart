import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vlookup_v2/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vlookup_v2/provider/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class EventDetailsPage extends StatefulWidget {
  final AppEvent event;

  const EventDetailsPage({super.key, required this.event});

  @override
  EventDetailsPageState createState() => EventDetailsPageState();
}

class EventDetailsPageState extends State<EventDetailsPage> {
  bool _isLoading = false;
  int _volunteerCount = 0;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController locationController;
  late TextEditingController phoneController;
  late AppEvent _updatedEvent;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descriptionController =
        TextEditingController(text: widget.event.description);
    dateController = TextEditingController(text: widget.event.date);
    locationController = TextEditingController(text: widget.event.location);
    phoneController = TextEditingController(text: widget.event.phone);
    _updatedEvent = widget.event;
    _fetchVolunteerCount();
  }

  String _formattedDate(String date) {
    DateTime parsedDate = DateFormat('dd MM yyyy h:mm').parse(date);
    return DateFormat('MMMM dd, yyyy h:mm a').format(parsedDate);
  }

  Future<void> _fetchVolunteerCount() async {
    final response = await http.get(
      Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/get_volunteer_count/${widget.event.event_id}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _volunteerCount = data['volunteer_count'];
      });
    } else {
      _showAlert('Error', 'Failed to load volunteer count.');
    }
  }

  Future<void> _volunteer() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      _showAlert('Error', 'No user logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://vlookup-api.ew.r.appspot.com/join_event'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': user.email,
        'event_id': widget.event.event_id,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      _showAlert(
          'Success', 'You have successfully volunteered for this event.');
      _fetchVolunteerCount();
    } else if (response.statusCode == 409) {
      _showAlert('Uh Oh', 'You have already joined this event');
    } else if (response.statusCode == 403) {
      _showAlert('Oh No', 'You cannot join an event you created');
    } else {
      _showAlert('Error', 'Failed to volunteer for the event.');
    }
  }

  Future<void> _editEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      _showAlert('Error', 'No user logged in');
      return;
    }

    final response = await http.put(
      Uri.parse('https://vlookup-api.ew.r.appspot.com/update_event'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'event_id': _updatedEvent.event_id,
        'title': titleController.text,
        'description': descriptionController.text,
        'date': dateController.text,
        'location': locationController.text,
        'phone_number': phoneController.text,
        'image': _updatedEvent.image,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showAlert('Success', 'Event updated successfully!');
    } else {
      _showAlert('Error', 'Failed to update event.');
    }
  }

  Future<void> _deleteEvent() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.delete(
      Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/delete_event/${widget.event.event_id}'),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showAlert('Success', 'Event deleted successfully!');
    } else {
      _showAlert('Error', 'Failed to delete event.');
    }
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd MM yyyy h:mm').format(picked);
      });
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
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  _removeImage(eventId);
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
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _updatedEvent =
              _updatedEvent.copyWith(image: responseData['file_url']);
        });
        _showAlert('Image Uploaded', 'The image was successfully uploaded.');
      } else {
        _showAlert('Upload Failed', 'Failed to upload image.');
      }
    } else {
      _showAlert('Image Upload Canceled', 'No image was selected.');
    }
  }

  Future<void> _removeImage(String eventId) async {
    setState(() {
      _updatedEvent = _updatedEvent.copyWith(
          image: 'assets/images/default_event_image.jpg');
    });

    final response = await http.put(
      Uri.parse('https://vlookup-api.ew.r.appspot.com/update_event'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'event_id': _updatedEvent.event_id,
        'image': 'assets/images/default_event_image.png',
      }),
    );

    if (response.statusCode == 200) {
      _showAlert('Success', 'Image removed successfully!');
    } else {
      _showAlert('Error', 'Failed to remove image.');
    }
  }

  void _showEditForm(BuildContext context) {
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(labelText: 'Date'),
                          onTap: () => _pickDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(labelText: 'Location'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: phoneController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _editEvent,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text('Update Event'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _promptForImageUpload(_updatedEvent.event_id),
                          child: const Text('Upload/Remove Image'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
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

  void launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await launchUrl(phoneUri)) {
    } else {
      // Handle the error, for example by showing a message to the user
      print('Could not launch dialer');
    }
  }

  void addEventToCalendar(inputEvent) {
    DateTime parsedDateTime =
        DateFormat('dd MM yyyy h:mm').parse(inputEvent.date);
    final Event event = Event(
      title: inputEvent.title,
      description:
          inputEvent.description.isNotEmpty ? inputEvent.description : null,
      location: inputEvent.location.isNotEmpty ? inputEvent.location : null,
      startDate: parsedDateTime,
      endDate: parsedDateTime.add(const Duration(hours: 1)),
    );

    Add2Calendar.addEvent2Cal(event);
  }

  String viewDateTime(String date) {
    DateTime parsedDate = DateFormat('dd MM yyyy h:mm').parse(date);
    return DateFormat('MMMM dd, yyyy h:mm a').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isCreator = user != null && user.email == widget.event.email;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.40;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      widget.event.image.startsWith('assets/')
                          ? Image.asset(
                              widget.event.image,
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.event.image,
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                            ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Event Title and Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.event.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Event Description
                            Text(
                              widget.event.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.location_pin,
                                    color: Colors.green,
                                  ),
                                  label: Text(
                                    widget.event.location,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${widget.event.location}'));
                                  },
                                ),
                                const Spacer(),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () {
                                    _showEditForm(context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Event Phone Number with Call Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.event.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      launchPhoneDialer(widget.event.phone);
                                    },
                                    child: const Icon(Icons.call)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  viewDateTime(widget.event.date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    addEventToCalendar(widget.event);
                                  },
                                  child: const Icon(Icons.calendar_month),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Number of Volunteers
                            Text(
                              'Volunteers: $_volunteerCount',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCreator)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _deleteEvent,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        textStyle:
                                            const TextStyle(fontSize: 18),
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )
                                          : const Text('Delete Event'),
                                    ),

                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Volunteer Button
              if (!isCreator)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _volunteer,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Volunteer'),
                    ),
                  ),
                ),
            ],
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
