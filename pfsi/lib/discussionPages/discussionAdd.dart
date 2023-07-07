import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';

class DiscussionAdd extends StatelessWidget {
  TextEditingController _questionController = TextEditingController();
  TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void logout() async {
      try {
        await FirebaseAuth.instance.signOut();
        // Perform any additional actions after logout
        print('Logout successful');
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      } catch (e) {
        // Handle logout errors
        print('Logout failed: $e');
      }
    }

    void goBack() {
      Navigator.pop(context);
    }

    Future<void> addDiscussion() async {
      final User? user = FirebaseAuth.instance.currentUser;
      String? uuid = user?.uid;
      if (uuid != null) {
        Map<String, dynamic> payload = {
          "topic": _topicController.text,
          "question": _questionController.text,
          "comments": [],
          "dateTimestamp": DateTime.now(),
          "userid": uuid
        };
        FirebaseFirestore.instance
            .collection('discussion_list')
            .add(payload)
            .then(
                (value) => {print("Discussion Added"), Navigator.pop(context)})
            .catchError((error) => print("Failed to add user: $error"));
      } else {
        print('no uuid');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Discussion',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: goBack,
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            )),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Topic",
                hintText: 'Enter your Topic',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              minLines: 3,
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Question",
                hintText: 'Enter your question',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Get the entered question
                String question = _questionController.text;
                String topic = _topicController.text;

                // Submit button logic here
                addDiscussion();
                print('Submitted question: $question $topic');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
