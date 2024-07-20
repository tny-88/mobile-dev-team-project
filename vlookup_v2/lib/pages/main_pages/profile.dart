import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/pages/main_pages/SplashOptionsPage.dart';
import 'package:vlookup_v2/pages/main_pages/created_events.dart';
import 'package:vlookup_v2/provider/user_provider.dart';

enum Menu { edit, change_password, logout }

List<PopupMenuEntry<Menu>> getPopupMenuItems() {
  return <PopupMenuEntry<Menu>>[
    const PopupMenuItem<Menu>(
      value: Menu.edit,
      child: ListTile(
        leading: Icon(Icons.edit),
        title: Text('Edit Profile'),
      ),
    ),
    const PopupMenuItem<Menu>(
      value: Menu.change_password,
      child: ListTile(
        leading: Icon(Icons.password_rounded),
        title: Text('Change Password'),
      ),
    ),
    const PopupMenuItem<Menu>(
      value: Menu.logout,
      child: ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
      ),
    ),
  ];
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController newPasswordController;
  late TextEditingController oldPasswordController;
  late TextEditingController dobController;
  String? _gender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    dobController = TextEditingController(text: user?.dob ?? '');
    _gender = user?.gender ?? '';
    newPasswordController = TextEditingController();
    oldPasswordController = TextEditingController();
  }

  Future<void> _getImage(ImageSource source, String email) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      var uri = Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/upload_profile_pic/$email');
      var request = http.MultipartRequest('PUT', uri)
        ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final fileUrl = responseData['file_url'];

        // Update the user's profile image in the provider
        Provider.of<UserProvider>(context, listen: false).setUser(
          Provider.of<UserProvider>(context, listen: false)
              .user!
              .copyWith(image: fileUrl),
        );

        _showAlert('Image Uploaded', 'The image was successfully uploaded.');
      } else {
        _showAlert('Upload Failed', 'Failed to upload image.');
      }
    } else {
      _showAlert('Image Upload Canceled', 'No image was selected.');
    }
  }

  void _promptForImageUpload(String email) {
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
                  _getImage(ImageSource.camera, email);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  _getImage(ImageSource.gallery, email);
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

  Future<void> _updateUserDetails() async {
    if (!_formKeyDetails.currentState!.validate()) {
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
      Uri.parse('https://vlookup-api.ew.r.appspot.com/update_user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': user.email,
        'name': nameController.text,
        'phone': phoneController.text,
        'gender': _gender,
        'dob': _selectedDate?.toIso8601String() ?? '',
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Provider.of<UserProvider>(context, listen: false).setUser(
        user.copyWith(
          name: nameController.text,
          phone: phoneController.text,
          gender: _gender,
          dob: _selectedDate?.toIso8601String() ?? '',
        ),
      );
      Navigator.pop(context);
      _showAlert('Success', 'User details updated successfully!');
    } else {
      _showAlert('Error', 'Failed to update user details.');
    }
  }

  Future<void> _changePassword() async {
    if (!_formKeyPassword.currentState!.validate()) {
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
      Uri.parse(
          'https://vlookup-api.ew.r.appspot.com/change_password/${user.email}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'oldPassword': oldPasswordController.text,
        'newPassword': newPasswordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      oldPasswordController.clear();
      newPasswordController.clear();
      Navigator.pop(context);
      _showAlert('Success', 'Password changed successfully!');
    } else {
      _showAlert('Error', 'Failed to change password.');
    }
  }

  void _pickDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setModalState(() {
        _selectedDate = picked;
        dobController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      });
    }
  }

  void _showEditDetailsForm(BuildContext context) {
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
                    key: _formKeyDetails,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: dobController,
                          decoration:
                              InputDecoration(labelText: 'Date of Birth'),
                          onTap: () => _pickDate(context, setModalState),
                          readOnly: true,
                        ),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(labelText: 'Gender'),
                          items: <String>['Male', 'Female', 'Other']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _gender = value;
                            });
                          },
                        ),
                        TextFormField(
                          controller: phoneController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateUserDetails,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text('Update Details'),
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

  void _showChangePasswordForm(BuildContext context) {
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
                    key: _formKeyPassword,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: oldPasswordController,
                          decoration:
                              InputDecoration(labelText: 'Old Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your old password';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: newPasswordController,
                          decoration:
                              InputDecoration(labelText: 'New Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your new password';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text('Change Password'),
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const Text('No user logged in');

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 245,
              color: const Color.fromRGBO(93, 176, 116, 1),
            ),
          ),
          // Profile picture and user info
          Positioned(
            top: 128,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _promptForImageUpload(user.email),
                    child: Container(
                      width: 158,
                      height: 158,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(100, 100, 100, 0.15),
                            offset: Offset(0, 4),
                            blurRadius: 20,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: user.image.startsWith('assets/')
                              ? AssetImage(user.image) as ImageProvider
                              : NetworkImage(user.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: PopupMenuButton<Menu>(
              icon: const Icon(Icons.settings, color: Colors.white),
              onSelected: (Menu item) {
                // Handle the selected menu item
                switch (item) {
                  case Menu.edit:
                    _showEditDetailsForm(context);
                    break;
                  case Menu.change_password:
                    _showChangePasswordForm(context);
                    break;
                  case Menu.logout:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SplashOptions()),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => getPopupMenuItems(),
            ),
          ),
          Positioned(
            top: 299,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.gender,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.phone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 7),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventCreatorPage(),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text(
                    'View Created Events',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
