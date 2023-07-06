import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';
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

  String selectedService = "";
  String selectedRegion = "";

  TextEditingController _questionController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();

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

    Future<void> addReview() async {
      final User? user = FirebaseAuth.instance.currentUser;
      String? uuid = user?.uid;
      if (uuid != null) {
        Map<String, dynamic> payload = {
          "business name": _businessNameController.text,
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
            TextField(
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
