import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';

class Review extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Perform any additional actions after logout
      print('Logout successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    } catch (e) {
      // Handle logout errors
      print('Logout failed: $e');
    }
  }

    return Scaffold(
          appBar: AppBar(
        title: Text(
          'Review',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: logout,
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        backgroundColor: Colors.red[300],
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                'Welcome To Review!',
                textAlign: TextAlign
                    .center, // Align the text within the center of the card
              ),
            ],
          ),
        ),
      ),
    );
  }
}
