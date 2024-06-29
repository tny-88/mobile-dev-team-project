import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'John Doe',
      'lastMessage': 'Hey, how are you?',
      'time': '10:30 AM',
      'avatar': 'assets/images/avatar1.jpg',
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Did you see the latest post?',
      'time': 'Yesterday',
      'avatar': 'assets/images/avatar2.jpg',
    },
    {
      'name': 'Mike Johnson',
      'lastMessage': 'Let\'s meet up tomorrow!',
      'time': '2 days ago',
      'avatar': 'assets/images/avatar3.jpg',
    },
    // Add more chat entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(_chats[index]['avatar']),
            ),
            title: Text(
              _chats[index]['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_chats[index]['lastMessage']),
            trailing: Text(
              _chats[index]['time'],
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Navigate to individual chat page
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement new chat functionality
        },
        child: Icon(Icons.chat),
      ),
    );
  }
}

// Implement the onTap functionality for each ListTile to navigate to individual chat pages.
// Implement the search functionality when the search icon is tapped.
// Implement the new chat functionality when the FloatingActionButton is pressed.