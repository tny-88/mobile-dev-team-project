import 'package:flutter/material.dart';
import 'package:vlookup_v2/pages/main_pages/Splash.dart';

enum Menu { edit, delete, logout }

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
      value: Menu.delete,
      child: ListTile(
        leading: Icon(Icons.delete_outlined),
        title: Text('Delete Account'),
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

          // Settings button with PopupMenuButton
          Positioned(
            top: 40,
            right: 20,
            child: PopupMenuButton<Menu>(
              icon: const Icon(Icons.settings, color: Colors.white),
              onSelected: (Menu item) {
                // Handle the selected menu item
                switch (item) {
                  case Menu.edit:
                    //add function to edit profile details
                    break;
                  case Menu.delete:
                    //Function to delete account
                    break;
                  case Menu.logout:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Splash()),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => getPopupMenuItems(),
            ),
          ),

          // Logout button
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
