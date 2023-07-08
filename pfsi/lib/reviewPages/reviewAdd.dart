import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'dart:convert';

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

class AddReview extends StatefulWidget {
  @override
  _AddReviewWidgetState createState() => _AddReviewWidgetState();
}

class _AddReviewWidgetState extends State<AddReview> {
  List<String> serviceOptions = [];
  List<String> regionsOptions = [];
  int _rating = 0;

  String selectedService = "";
  String selectedRegion = "";

  TextEditingController _commentController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _pricingController = TextEditingController();

  Future<String> _loadJsonData() async {
    return await rootBundle.loadString('review-options.json');
  }

  Future<List<String>> _getServiceOptionsFromJson() async {
    String jsonData = await _loadJsonData();
    ServiceData serviceData = ServiceData.fromJson(json.decode(jsonData));
    List<String> services = serviceData.services;
    return services;
  }

  Future<List<String>> _getRegionsOptionsFromJson() async {
    String jsonData = await _loadJsonData();
    ServiceData regionsData = ServiceData.fromJson(json.decode(jsonData));
    List<String> regions = regionsData.regions;
    return regions;
  }

  @override
  void initState() {
    super.initState();
    _getServiceOptionsFromJson().then((value) {
      setState(() {
        serviceOptions = value;
        selectedService = serviceOptions[
            0]; // Set the first option as the default selected option
      });
    });
    _getRegionsOptionsFromJson().then((value) {
      setState(() {
        regionsOptions = value;
        selectedRegion = regionsOptions[
            0]; // Set the first option as the default selected option
      });
    });
  }

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

    void displaySnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Future<void> addReview() async {
      final User? user = FirebaseAuth.instance.currentUser;
      String? uuid = user?.uid;
      if (uuid != null) {
        if (_businessNameController.text.isEmpty) {
          displaySnackBar(context, 'Business Name can\'t be empty');
          return;
        }
        if (_rating == 0) {
          displaySnackBar(context, 'Please select a rating');
          return;
        }
        if (_pricingController.text.isEmpty) {
          displaySnackBar(context, 'Please set a price');
          return;
        }
        if (selectedService == '--Services--') {
          displaySnackBar(context, 'Please select a service');
          return;
        }
        if (selectedRegion == '--Regions--') {
          displaySnackBar(context, 'Please select a region');
          return;
        }
        Map<String, dynamic> payload = {
          "businessName": _businessNameController.text,
          "comment": _commentController.text,
          "dateTimestamp": DateTime.now(),
          "userid": uuid,
          "pricing": int.parse(_pricingController.text),
          "rating": _rating,
          "region": selectedRegion,
          "service": selectedService
        };
        FirebaseFirestore.instance
            .collection('review_list')
            .add(payload)
            .then((value) => {print("Review Added"), Navigator.pop(context)})
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
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value!;
                });
              },
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
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRegion = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select a region',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _businessNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Business Name",
                hintText: 'Enter the business name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _pricingController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
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
                                setState(() {
                                  _rating = i;
                                });
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
            ElevatedButton(
              onPressed: () {
                // Get the entered question

                // Submit button logic here
                addReview();
                // print('Submitted question: $question $topic');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
