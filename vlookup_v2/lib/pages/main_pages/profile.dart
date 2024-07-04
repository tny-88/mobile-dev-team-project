import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/provider/user_provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
                  image: const DecorationImage(
                    image: AssetImage('/assets/images/profile.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                  style:const TextStyle(
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
                const SizedBox(height: 5),
                Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              color: const Color.fromRGBO(93, 176, 116, 1),
            ),
          ),
        ],
      ),
    );
  }
}