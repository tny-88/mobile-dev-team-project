import 'package:flutter/material.dart';
import 'package:vlookup_v2/pages/main_pages/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Text(
            'Log In',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: TextButton(
                    onPressed: () {
                      // Show/Hide password logic
                    },
                    child: Text('Show'),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  //Function for Login validation
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 93, 176, 117),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Log In',
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
    );
  }
}


