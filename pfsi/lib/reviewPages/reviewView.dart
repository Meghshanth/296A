import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;

class ServiceData {
  final List<String> services;
  final List<String> regions;

  ServiceData({required this.services, required this.regions});

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      services: List<String>.from(json['services']),
      regions: List<String>.from(json['regions']),
    );
  }
}

class Review {
  final String region;
  final String service;
  final String businessName;
  final String userid;
  final double pricing;
  final int rating;
  final String comment;

  Review(
      {required this.region,
      required this.service,
      required this.businessName,
      required this.userid,
      required this.pricing,
      required this.rating,
      required this.comment});

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
        region: map['region'],
        service: map['service'],
        businessName: map['businessName'],
        userid: map['userid'],
        pricing: map['pricing'],
        rating: map['rating'],
        comment: map['comment']);
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
  int _rating = 0;
  String selectedService = "";
  String selectedRegion = "";
  String uuid = "";
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _pricingController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  List<String> serviceOptions = [];
  List<String> regionsOptions = [];

  bool isLoading = true;
  Review? review;
  bool isEditable = false;

  Future<List<String>> _getServiceOptionsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('services_list').get();

      List<String> services = [];
      querySnapshot.docs.forEach((documentSnapshot) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['services'] != null) {
          List<dynamic>? servicesList = data['services'];
          if (servicesList != null) {
            services.addAll(servicesList.cast<String>());
          }
        }
      });

      return services;
    } catch (e) {
      // Handle error
      print('Error fetching services: $e');
      return [];
    }
  }

  Future<List<String>> _getRegionsOptionsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('regions_list').get();

      List<String> regions = [];
      querySnapshot.docs.forEach((documentSnapshot) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['regions'] != null) {
          List<dynamic>? regionList = data['regions'];
          if (regionList != null) {
            regions.addAll(regionList.cast<String>());
          }
        }
      });
      return regions;
    } catch (e) {
      // Handle error
      print('Error fetching regions: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _getServiceOptionsFromFirebase().then((value) {
      setState(() {
        serviceOptions = value;
        if (serviceOptions.isNotEmpty) {
          selectedService = serviceOptions[0]; // Add this line
        }
      });
      _getRegionsOptionsFromFirebase().then((value) {
        setState(() {
          regionsOptions = value;
          if (regionsOptions.isNotEmpty) {
            selectedRegion = regionsOptions[0]; // Add this line
          }
        });
        fetchDocumentById(widget.documentId);
      });
    });
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
        _businessNameController.text = review!.businessName;
        _commentController.text = review!.comment;
        _pricingController.text = review!.pricing.toString();
        setState(() {
          final User? user = FirebaseAuth.instance.currentUser;
          uuid = user!.uid;
          selectedRegion = review!.region;
          selectedService = review!.service;
          _rating = review!.rating;
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
        'region': selectedRegion,
        'businessName': _businessNameController.text,
        'service': selectedService,
        'pricing': double.parse(_pricingController.text),
        'rating': _rating,
        'comment': _commentController.text
      });

      // Disable editing
      print("Review Edited");
      Navigator.pop(context);
    } catch (e) {
      // Handle update error
      print('Update failed: $e');
    }
  }

  void deleteReview() async {
    try {
      await FirebaseFirestore.instance
          .collection('review_list')
          .doc(documentId)
          .delete();

      print("Review Deleted");
      Navigator.pop(context);
    } catch (e) {
      // Handle delete error
      print('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Review',
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
            DropdownButtonFormField<String>(
              value: selectedService,
              items: serviceOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  key: ValueKey(option),
                  child: Text(option),
                );
              }).toList(),
              onChanged: isEditable
                  ? (value) => setState(() => selectedService = value!)
                  : null,
              decoration: InputDecoration(
                labelText: 'Select a service',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              items: regionsOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  key: ValueKey(option),
                  child: Text(option),
                );
              }).toList(),
              onChanged: isEditable
                  ? (value) => setState(() => selectedRegion = value!)
                  : null,
              decoration: InputDecoration(
                labelText: 'Select a region',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              enabled: isEditable,
              controller: _businessNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Business Name",
                hintText: 'Enter the business name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              enabled: isEditable,
              controller: _pricingController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter price',
                prefixText: '\$',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Rating:',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 1; i <= 5; i++)
                            GestureDetector(
                              onTap: () {
                                if (isEditable) {
                                  setState(() {
                                    _rating = i;
                                  });
                                }
                              },
                              child: Icon(
                                i <= _rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      _rating.toString() + "/5",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
            SizedBox(height: 16.0),
            TextField(
              enabled: isEditable,
              controller: _commentController,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Comment",
                hintText: 'Enter your comment',
              ),
            ),
            SizedBox(height: 16.0),
            if (!isLoading)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Updated MainAxisAlignment
                children: [
                  ElevatedButton(
                    onPressed: isEditable ? () => saveFields() : null,
                    child: Text('Submit'),
                  ),
                  if (userid == uuid)
                    ElevatedButton(
                      onPressed: isEditable ? () => deleteReview() : null,
                      child: Text('Delete'),
                    ),
                ],
              ),
          ],
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
