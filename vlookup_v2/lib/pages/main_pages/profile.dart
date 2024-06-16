import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Container(
          width: 399,
          height: 844,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: <Widget>[
              // Green background
              Positioned(
                  top: 0,
                  left: -1,
                  child: Container(
                    width: 400,
                    height: 245,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(93, 176, 116, 1),
                    ),
                  )),

              // Profile picture
              Positioned(
                top: 128,
                left: 120,
                child: Container(
                  width: 158,
                  height: 158,
                  decoration: BoxDecoration(
                    boxShadow: [
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
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile_picture.png'),
                      fit: BoxFit.fitWidth,
                    ),
                    borderRadius: BorderRadius.circular(158),
                  ),
                ),
              ),

              // Name
              Positioned(
                top: 299,
                left: 88,
                child: Text(
                  'James Boateng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              // Green bar on the bottom
              Positioned(
                top: 788,
                left: 0,
                child: Container(
                  width: 390,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(93, 176, 116, 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
