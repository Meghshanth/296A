import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/reviewPages/reviewAdd.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

Future<String> _loadJsonData() async {
  return await rootBundle.loadString('review-options.json');
}

class _ReviewPageState extends State<Review> with TickerProviderStateMixin {
  String selectedService = "";
  List<String> serviceOptions = [];
  String _selectedReviewType = 'All reviews';
  final ValueNotifier<String> _selectedReviewTypeNotifier =
      ValueNotifier<String>('All reviews');

  Future<List<String>> _getServiceOptionsFromJson() async {
    String jsonData = await _loadJsonData();
    ServiceData serviceData = ServiceData.fromJson(json.decode(jsonData));
    List<String> services = serviceData.services;
    return services;
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
  }

  @override
  void dispose() {
    _selectedReviewTypeNotifier.dispose();
    super.dispose();
  }

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
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: selectedService != '--Services--'
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              SizedBox(width: 20),
              Align(
                  alignment: Alignment.center,
                  child: Column(children: [
                    ValueListenableBuilder<String>(
                      valueListenable: _selectedReviewTypeNotifier,
                      builder: (context, value, child) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select review type',
                          ),
                          value: value,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReviewType = newValue!;
                            });
                            _selectedReviewTypeNotifier.value = newValue!;
                          },
                          items: <String>[
                            'All reviews',
                            'Your reviews',
                          ].map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
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
                          if (serviceOptions[0] == '--Services--') {
                            serviceOptions.removeAt(0);
                          }
                          selectedService = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select a service',
                      ),
                    ),
                  ])),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReview()),
          );
        },
        backgroundColor: Colors.red[300],
        tooltip: 'Add a new Review',
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
