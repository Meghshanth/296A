import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';

class DiscussionAdd extends StatelessWidget {
  TextEditingController _questionController = TextEditingController();
  TextEditingController _topicController = TextEditingController();

  // Replace 'your_collection' with the name of your collection in Firestore
// Replace 'your_document_id' with the ID of the document you want to retrieve
  // Future<void> getDocument() async {
  //   FirebaseFirestore.instance
  //       .collection('discussion_list')
  //       .doc('QC1FGo4WqoSM3BdxQUVD')
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       print('Document data: ${documentSnapshot.data()}');
  //     } else {
  //       print('Document does not exist on the database');
  //     }
  //   });
  // }

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
            .then((value) => print("User Added"))
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
          'Discussion',
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
                hintText: 'Enter your Topic',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
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
