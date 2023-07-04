import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';

class DiscussionView extends StatelessWidget {
  String documentId = '';
  DiscussionView(String documentId) {
    this.documentId = documentId;
  }
  TextEditingController _questionController = TextEditingController();
  TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> fetchDocumentById(String documentId) async {
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('discussion_list')
            .doc(documentId)
            .get();

        if (documentSnapshot.exists) {
          // Document exists
          Map<String, dynamic> dataObj = documentSnapshot.data() as Map<String,
              dynamic>; // Save the document data in dataObj variable
          print(dataObj);
          _topicController.text = dataObj['topic'];
          _questionController.text = dataObj['question'];
        } else {
          // Document does not exist
          print('Document does not exist');
        }
      } catch (e) {
        // Error occurred
        print('Error: $e');
      }
    }

    fetchDocumentById(documentId);

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
          'View Discussion',
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
              enabled: false,
              controller: _topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your Topic',
                labelText: "Topic",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              enabled: false,
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your question',
                  labelText: "Question"),
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
