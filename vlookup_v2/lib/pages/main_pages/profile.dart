import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vlookup_v2/provider/user_provider.dart';
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
        ],
      ),
    );
  }
}
