import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vlookup_v2/models/event_model.dart';
import 'package:vlookup_v2/pages/main_pages/events_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
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
  File? _image;
  final ImagePicker _picker = ImagePicker();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

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

  //Function that allows user to take a photo or choose from gallery
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  //Function that clears any image or date or location the user has taken when the form is closed
  void reset() {
    setState(() {
      _image = null; // Reset the image when the form is closed
    });

    dateTimeController
        .clear(); // Reset the date and time when the form is closed
  }

  // Function that brings up date and time picker
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
          selectedDate = pickedDate;
          selectedTime = pickedTime;
          dateTimeController.text =
              '${DateFormat('dd MMM yyyy').format(selectedDate!)} ${selectedTime!.format(context)}';
        });
      }
    }
  }

  // Function to add Calendar event to local calendar
  void addEventToCalendar(title, description, location, dateTime) {
    if(dateTime.text.isNotEmpty) {
      final DateTime parsedDateTime = DateFormat('dd MMM yyyy HH:mm').parse(dateTime.text);
      final Event event = Event(
        title: title.text,
        description: description.text,
        location: location.text,
        startDate: parsedDateTime,
        endDate: parsedDateTime.add(const Duration(hours: 1)),
        );

      Add2Calendar.addEvent2Cal(event);
    }
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
              reset();
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
                          TextField(
                            decoration: const InputDecoration(labelText: 'Title'),
                            controller: titleController,
                          ),
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            controller: descriptionController,
                          ),
                          if (dateTimeController.text.isEmpty)
                            TextButton.icon(
                              onPressed: () {
                                pickDateTime(context, setModalState);
                              },
                              icon: const Icon(Icons.date_range_outlined),
                              label: const Text('Add Date and Time'),
                            )
                          else
                            TextButton.icon(
                              onPressed: () {
                                pickDateTime(context, setModalState);
                              },
                              icon: const Icon(Icons.date_range_outlined),
                              label: Text(dateTimeController.text),
                            ),
                          TextButton.icon(
                            onPressed: () {
                              //Loction picker;
                            },
                            icon: const Icon(Icons.location_on_sharp),
                            label: const Text('Add Location'),
                          ),
                          ElevatedButton(
                            onPressed: () {                              
                              // Add event to local calendar
                              addEventToCalendar(titleController, descriptionController, locationController, dateTimeController);

                              // TODO - Send content to API


                              Navigator.pop(context);
                              reset();
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
