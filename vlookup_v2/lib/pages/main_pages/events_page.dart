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

  Future<List<dynamic>> _fetchVolunteers() async {
    final response = await http.get(
      Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/get_volunteers/${widget.event.event_id}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _showAlert('Error', 'Failed to load volunteers');
      return []; // Return an empty list if there's an error
    }
  }

  void _checkVolunteerStatus() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final volunteers = await _fetchVolunteers();
      setState(() {
        _isVolunteered = volunteers.any((v) => v['email'] == user.email);
      });
    }
  }

  void _showVolunteerDetails() async {
    try {
      final volunteers = await _fetchVolunteers();
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          // Check if the volunteer list is empty
          if (volunteers.isEmpty) {
            return Container(
              height: 200, // Smaller container for the "No Volunteers" message
              alignment: Alignment.center,
              child: const Text(
                'No Volunteers',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            );
          } else {
            return Container(
              height: 400,
              child: ListView.builder(
                itemCount: volunteers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(volunteers[index]['name']),
                    subtitle: Text(volunteers[index]['email']),
                  );
                },
              ),
            );
          }
        },
      );
    } catch (e) {
      _showAlert('Error', 'Failed to fetch volunteer details.');
    }
  }

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
    _fetchVolunteerCount()
        .then((_) => _checkVolunteerStatus()); // Chain these calls
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
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
      if (mounted) {
        setState(() {
          _volunteerCount = data['volunteer_count'];
        });
      }
    } else {
      _showAlert('Error', 'Failed to load volunteer count.');
    }
  }

  bool _isVolunteered = false; // State to track if the user has volunteered

  Future<void> _volunteer() async {
    // If already volunteered, run the leave event function instead
    if (_isVolunteered) {
      _leaveEvent();
      return;
    }

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
      _isVolunteered = true;
      _fetchVolunteerCount().then((_) => _checkVolunteerStatus());
    } else if (response.statusCode == 409) {
      _showAlert('Uh Oh', 'You have already joined this event');
    } else if (response.statusCode == 403) {
      _showAlert('Oh No', 'You cannot join an event you created');
    } else {
      _showAlert('Error', 'Failed to volunteer for the event.');
    }
  }

  Future<void> _leaveEvent() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      _showAlert('Error', 'No user logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.delete(
      Uri.parse('https://vlookup-api.ew.r.appspot.com/leave_event'),
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
      _showAlert('Success', 'You have successfully left the event.');
      _isVolunteered = false;
      _fetchVolunteerCount().then((_) => _checkVolunteerStatus());
    } else {
      _showAlert('Error', 'Failed to leave the event.');
    }
  }

  Future<void> _editEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showAlert('Success', 'Event updated successfully!');
    } else {
      _showAlert('Error', 'Failed to update event.');
    }
  }

  Future<void> _deleteEvent() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final response = await http.delete(
      Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/delete_event/${widget.event.event_id}'),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

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
        if (mounted) {
          setState(() {
            _updatedEvent =
                _updatedEvent.copyWith(image: responseData['file_url']);
          });
        }
        _showAlert('Image Uploaded', 'The image was successfully uploaded.');
      } else {
        _showAlert('Upload Failed', 'Failed to upload image.');
      }
    } else {
      _showAlert('Image Upload Canceled', 'No image was selected.');
    }
  }

  Future<void> _removeImage(String eventId) async {
    if (mounted) {
      setState(() {
        _updatedEvent = _updatedEvent.copyWith(
            image: 'assets/images/default_event_image.jpg');
      });
    }

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
                                Text(
                                  viewDateTime(widget.event.date),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 149, 149, 149),
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
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_pin,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(
                                          width:
                                              8), // Space between icon and text
                                      Text(
                                        widget.event.location,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                const Spacer(),
                                if (isCreator)
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                    onPressed: () {
                                      _showEditForm(context);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            //Creator of event text
                            Text(
                              'Created by: ${widget.event.email}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // Number of Volunteers
                            InkWell(
                              onTap: _showVolunteerDetails,
                              child: Text(
                                'Volunteers: $_volunteerCount',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Event Phone Number with Call Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Contact Us',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      launchPhoneDialer(widget.event.phone);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation:
                                          2, // button's elevation when it's pressed
                                    ),
                                    child: const Icon(
                                      Icons.call,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Open in Maps',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=${widget.event.location}'));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation:
                                          2, // button's elevation when it's pressed
                                    ),
                                    child: const Icon(
                                      Icons.map_outlined,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Add event to your calendar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    addEventToCalendar(widget.event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation:
                                        2, // button's elevation when it's pressed
                                  ),
                                  child: const Icon(Icons.calendar_month),
                                )
                              ],
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
                        backgroundColor: _isVolunteered
                            ? Colors.red
                            : Colors.green, // Change color based on status
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white))
                          : Text(_isVolunteered
                              ? 'Leave Event'
                              : 'Volunteer'), // Change text based on status
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
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
