import 'package:flutter/material.dart';

class TermsAndPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Policy Agreement',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to the Volunteer App. By registering as a volunteer, you agree to the following terms and policies:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Commitment:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'As a volunteer, you commit to dedicating your time and skills to the activities and events you sign up for. It is expected that you will honor your commitments and notify us in advance if you are unable to attend any event.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. Conduct:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Volunteers are expected to conduct themselves in a respectful and professional manner at all times. This includes treating all participants, other volunteers, and organizers with respect and courtesy.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. Confidentiality:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'You may have access to confidential information during your volunteering activities. It is important that you do not disclose any personal or sensitive information to unauthorized individuals.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Safety:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Your safety and the safety of others is paramount. Please adhere to all safety guidelines and procedures provided by the event organizers. Report any unsafe conditions or incidents to the organizers immediately.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. Media Consent:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'By participating in volunteer activities, you consent to being photographed or recorded. These media may be used for promotional purposes by the organization.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '6. Termination:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'The organization reserves the right to terminate your volunteer status at any time if you violate these terms and policies or engage in any conduct deemed inappropriate or harmful.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'By registering, you acknowledge that you have read, understood, and agree to these terms and policies.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
