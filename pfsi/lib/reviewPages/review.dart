import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/reviewPages/reviewAdd.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import '../discussionPages/discussionView.dart';

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
  String selectedRegion = "";

  List<String> serviceOptions = [];
  List<String> regionOptions = [];

  String _selectedReviewType = 'All reviews';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<String> _selectedReviewTypeNotifier =
      ValueNotifier<String>('All reviews');
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<String>> _getServiceOptionsFromJson() async {
    String jsonData = await _loadJsonData();
    ServiceData serviceData = ServiceData.fromJson(json.decode(jsonData));
    List<String> services = serviceData.services;
    return services;
  }

  Future<List<String>> _getRegionsOptionsFromJson() async {
    String jsonData = await _loadJsonData();
    ServiceData serviceData = ServiceData.fromJson(json.decode(jsonData));
    List<String> regions = serviceData.regions;
    return regions;
  }

  @override
  void initState() {
    super.initState();
    _getServiceOptionsFromJson().then((value) {
      setState(() {
        serviceOptions = value;
        selectedService = serviceOptions.isNotEmpty ? serviceOptions[0] : '';

        // selectedService = serviceOptions[
        //     0]; // Set the first option as the default selected option
      });
    });

    _getRegionsOptionsFromJson().then((value) {
      setState(() {
        regionOptions = value;
        selectedRegion = regionOptions.isNotEmpty ? regionOptions[0] : '';

        // selectedService = serviceOptions[
        //     0]; // Set the first option as the default selected option
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
    String? uuid = user?.uid;

    Stream<QuerySnapshot>? _fetchData() {
      if (selectedService != '' &&
          selectedService != '--Services--' &&
          selectedRegion != '' &&
          selectedRegion != '--Region--') {
        Query query = _firestore
            .collection('review_list')
            .orderBy('dateTimestamp', descending: true)
            .where('service',
                isEqualTo: selectedService); // Order by a field for pagination
        query = query.where('region', isEqualTo: selectedRegion);
        // .limit(_perPage); // Limit the number of documents per page
        if (_selectedReviewType == 'Your reviews') {
          query = query.where('userid', isEqualTo: uuid);
        }
        return query.snapshots();
        // return query.snapshots().handleError((error) {
        //   // Handle the error here
        //   print('Error fetching data: $error');
        // });
      } else {
        return null;
      }
    }

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
                    value: selectedRegion,
                    items: regionOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (regionOptions[0] == '--Region--') {
                          regionOptions.removeAt(0);
                        }
                        selectedRegion = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select a region',
                    ),
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
            if (selectedService != '--Services--')
              Flexible(
                child: ValueListenableBuilder<String>(
                  valueListenable: _selectedReviewTypeNotifier,
                  builder: (context, selectedOption, child) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: _fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final documents = snapshot.data!.docs;
                          if (documents.isNotEmpty) {
                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final data = documents[index].data()
                                    as Map<String, dynamic>;
                                return Column(
                                  children: [
                                    InkWell(
                                      splashColor: Colors.red,
                                      hoverColor: Colors.red[200],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DiscussionView(
                                              documents[index].id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        title: Text(data['businessName']),
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                );
                              },
                            );
                          } else {
                            return Card(
                              margin: EdgeInsets.only(top: 16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No reviews found for this category',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Text('Error!!!: ${snapshot.error}');
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
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
