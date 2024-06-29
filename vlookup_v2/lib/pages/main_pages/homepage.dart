import 'package:flutter/material.dart';
import 'package:vlookup_v2/widgets/custom_nav_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: ListView.builder(
        itemCount: 5, // number of items in the list
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: <Widget>[
                Image.asset(
                    'assets/images/image_${index + 1}.jpg'), // replace with your image assets
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Title ${index + 1}',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Description ${index + 1}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
