import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';

class Review {
  final String region;
  final String service;
  final String businessName;
  final String userid;
  final int pricing;
  final int rating;

  Review({
    required this.region,
    required this.service,
    required this.businessName,
    required this.userid,
    required this.pricing,
    required this.rating,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      region: map['region'],
      service: map['service'],
      businessName: map['businessName'],
      userid: map['userid'],
      pricing: map['pricing'],
      rating: map['rating'],
    );
  }
}

class ReviewView extends StatefulWidget {
  final String documentId;

  ReviewView(this.documentId);

  @override
  _ReviewViewState createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  String userid = '';
  String documentId = '';
  TextEditingController _regionController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _serviceController = TextEditingController();
  bool isLoading = true;
  Review? review;
  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    fetchDocumentById(widget.documentId);
  }

  Future<void> fetchDocumentById(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('review_list')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        review = Review.fromMap(data!);
        _regionController.text = review!.region;
        _businessNameController.text = review!.businessName;
        _serviceController.text = review!.service;
        setState(() {
          userid = review!.userid;
          this.documentId = documentId;
          isLoading = false;
          isEditable = FirebaseAuth.instance.currentUser?.uid == userid;
        });
      } else {
        // Document does not exist
        print('Document does not exist');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Error occurred
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
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

  void editFields() {
    if (isEditable) {
      // Cancel editing
      setState(() {
        isEditable = false;
      });
    } else {
      // Check if the current user gave the review
      if (FirebaseAuth.instance.currentUser?.uid == review?.userid) {
        // Enable editing
        setState(() {
          isEditable = true;
        });
      }
    }
  }


void saveFields() async {
  // Update the review document in Firebase
  try {
    await FirebaseFirestore.instance
        .collection('review_list')
        .doc(documentId)
        .update({
          'region': _regionController.text,
          'businessName': _businessNameController.text,
          'service': _serviceController.text,
        });

    // Disable editing
    setState(() {
      isEditable = false;
    });
  } catch (e) {
    // Handle update error
    print('Update failed: $e');
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'View Review',
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
        if (isEditable)
          IconButton(
            onPressed: saveFields,
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        IconButton(
          onPressed: logout,
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
      ],
      backgroundColor: Colors.red[300],
    ),
    body: isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
            child: SingleChildScrollView(
              child: Container(
                width: 300,
                height: 400,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Text(
                              'Region:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                enabled: isEditable,
                                controller: _regionController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter your region',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              'Business Name:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                enabled: isEditable,
                                controller: _businessNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter your business name',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              'Service:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                enabled: isEditable,
                                controller: _serviceController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter your service',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isEditable)
                              ElevatedButton(
                                onPressed: saveFields,
                                child: Text('Save'),
                              ),
                            if (!isEditable && FirebaseAuth.instance.currentUser?.uid == review?.userid)
                              ElevatedButton(
                                onPressed: editFields,
                                child: Text('Edit'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
  );
}

}

void main() {
  runApp(MaterialApp(
    home: ReviewView('documentId'),
  ));
}


