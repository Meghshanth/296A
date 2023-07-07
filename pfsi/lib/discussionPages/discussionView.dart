import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:intl/intl.dart';

class Discussion {
  final String topic;
  final String question;
  final Timestamp dateTimestamp;
  final String userid;
  final List<dynamic> comments;

  Discussion({
    required this.topic,
    required this.question,
    required this.dateTimestamp,
    required this.userid,
    required this.comments,
  });

  factory Discussion.fromMap(Map<String, dynamic> map) {
    final List<dynamic> comments = map['comments'];

    return Discussion(
      topic: map['topic'],
      question: map['question'],
      dateTimestamp: map['dateTimestamp'],
      userid: map['userid'],
      comments: comments,
    );
  }
}

class DiscussionView extends StatefulWidget {
  final String documentId;

  DiscussionView(this.documentId);

  @override
  _DiscussionViewState createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView> {
  List<dynamic> comments = [];
  String userid = '';
  TextEditingController _questionController = TextEditingController();
  TextEditingController _topicController = TextEditingController();
  TextEditingController _replyController = TextEditingController();
  String documentId = '';

  @override
  void initState() {
    super.initState();
    fetchDocumentById(widget.documentId);
  }

  Future<void> fetchDocumentById(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('discussion_list')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        Discussion discussion = Discussion.fromMap(data!);
        _topicController.text = discussion.topic;
        _questionController.text = discussion.question;
        setState(() {
          comments = discussion.comments;
          userid = discussion.userid;
          this.documentId = documentId;
        });
      } else {
        // Document does not exist
        print('Document does not exist');
      }
    } catch (e) {
      // Error occurred
      print('Error: $e');
    }
  }

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

  Future<void> addComment() async {
    final User? user = FirebaseAuth.instance.currentUser;
    String? uuid = user?.uid;
    if (uuid != null) {
      Map<String, dynamic> newComment = {
        'userid': userid,
        'reply': _replyController.text,
        'dateTimestamp': Timestamp.now()
      };
      comments.insert(0, newComment);
      print(this.documentId);
      FirebaseFirestore.instance
          .collection('discussion_list')
          .doc(this.documentId)
          .update({'comments': comments})
          .then((value) => {print("Comment Added"), Navigator.pop(context)})
          .catchError((error) => print("Failed to add user: $error"));
    } else {
      print('no uuid');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ),
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
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your question',
                labelText: "Question",
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Card(
                color: const Color.fromARGB(255, 252, 242, 243),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Replies',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ListTile(
                                  title: Text(comments[index]['reply']),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                          style: TextStyle(fontSize: 12),
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(comments[index]
                                                      ['dateTimestamp']
                                                  .toDate())),
                                      SizedBox(width: 16.0),
                                      if (comments[index]['userid'] == userid)
                                        Container(
                                          padding: EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.red[300],
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                          child: Text(
                                            "OP",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )),
                              Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                        margin: EdgeInsets.all(2.0),
                        child: TextField(
                          controller: _replyController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your Reply',
                            labelText: "Reply",
                          ),
                        )),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addComment();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DiscussionView('documentId'),
  ));
}
