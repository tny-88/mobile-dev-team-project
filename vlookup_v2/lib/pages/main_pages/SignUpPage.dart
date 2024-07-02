import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vlookup_v2/pages/main_pages/LogInPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _phoneError;
  String? _emailError;
  String? selectedGender;
  DateTime? _selectedDate;
  bool _newsletter = false;
  bool _termsAccepted = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(
          child: Text(
            'Sign Up',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onTap: () => _pickDate(context),
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        items: <String>[
                          'Male',
                          'Female',
                          'Other',
                          'Prefer not to say'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    errorText: _phoneError,
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _phoneError = 'Phone number is required';
                      } else if (value.length != 10) {
                        _phoneError = 'Phone number must be 10 digits';
                      } else {
                        _phoneError = null;
                      }
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _emailError = 'Email is required';
                      } else if (!_isValidEmail(value)) {
                        _emailError = 'Enter a valid email address';
                      } else {
                        _emailError = null;
                      }
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Checkbox(
                      value: _newsletter,
                      onChanged: (value) {
                        setState(() {
                          _newsletter = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I would like to receive your newsletter and other promotional information.',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            'I understand the',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          TextButton(
                            onPressed: () {
                              // Logic for Open terms and policy page
                            },
                            child: const Text(
                              'terms & policy.',
                              style: TextStyle(
                                fontSize: 12.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 93, 176, 117),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Forgot password logic
                  },
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(color: Color.fromARGB(255, 93, 176, 117)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}