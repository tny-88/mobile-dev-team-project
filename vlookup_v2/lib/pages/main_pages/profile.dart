import 'package:flutter/material.dart';
import 'package:vlookup_v2/pages/main_pages/Splash.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Green background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 245,
              color: const Color.fromRGBO(93, 176, 116, 1),
            ),
          ),

          // Settings button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Add settings functionality
              },
            ),
          ),

          // // Logout button
          // Positioned(
          //   top: 40,
          //   right: 20,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.red,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(18.0),
          //       ),
          //     ),
          //     child:
          //         const Text('Logout', style: TextStyle(color: Colors.white)),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const Splash()),
          //       );
          //     },
          //   ),
          // ),

          // Profile picture
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
                    image: AssetImage('assets/images/profile.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Name and Gender
          Positioned(
            top: 299,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'James Boateng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Male',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Green bar on the bottom
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
