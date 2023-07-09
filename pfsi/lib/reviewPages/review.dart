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
  String selectedService = "All Services";
  String selectedRegion = "All Regions";

  final ValueNotifier<String> averagePriceNotifier = ValueNotifier('');
  final ValueNotifier<String> averageRatingNotifier = ValueNotifier('');

  List<String> serviceOptions = [];
  List<String> regionOptions = [];

  String _selectedReviewType = 'All reviews';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  Widget build(BuildContext context) {
    String? uuid = user?.uid;

    Stream<QuerySnapshot>? _fetchData() {
      Query query = _firestore
          .collection('review_list')
          .orderBy('dateTimestamp', descending: true);
      // .limit(_perPage); // Limit the number of documents per page
      if (selectedService != 'All Services') {
        query = query.where('service', isEqualTo: selectedService);
      }
      if (selectedRegion != 'All Regions') {
        query = query.where('region', isEqualTo: selectedRegion);
      }
      if (_selectedReviewType == 'Your reviews') {
        query = query.where('userid', isEqualTo: uuid);
      }

      // snapshots.listen((QuerySnapshot snapshot) {
      //   // Process the documents here

      //   List<QueryDocumentSnapshot> documents = snapshot.docs;
      //   agregateData(documents, snapshot.size);
      // });

      Stream<QuerySnapshot> snapshots = query.snapshots();

      snapshots.take(1).listen((QuerySnapshot snapshot) {
        List<QueryDocumentSnapshot> documents = snapshot.docs;
        List<Object?> dataList = documents.map((doc) => doc.data()).toList();

        // Call your function to aggregate the data
        aggregateData(dataList);
      });

      return snapshots;

      // return query.snapshots();

      // return query.snapshots().handleError((error) {
      //   // Handle the error here
      //   print('Error fetching data: $error');
      // });
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            Align(
                alignment: Alignment.center,
                child: Card(
                    margin: EdgeInsets.only(top: 16),
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(children: [
                          Text(
                            'Filters',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedReviewType,
                            items: <String>[
                              'All reviews',
                              'Your reviews',
                            ].map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedReviewType = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select review type',
                            ),
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
                                selectedService = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select a service',
                            ),
                          ),
                        ])))),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                    child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Average Pricing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(height: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: averagePriceNotifier,
                          builder: (context, value, _) {
                            if (selectedService == 'All Services') {
                              return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Select a Service',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ));
                            } else if (value == 'NoRecords') {
                              return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No Records',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ));
                            } else {
                              return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '\$$value',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )),
                Expanded(
                    child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Average Rating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(height: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: averageRatingNotifier,
                          builder: (context, value, _) {
                            if (value == 'NoRecords') {
                              return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No Records',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ));
                            } else {
                              return Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$value',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ],
                                  ));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
            Flexible(
              child: Card(
                  margin: EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        'Reviews',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Flexible(
                          child: StreamBuilder<QuerySnapshot>(
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
                                          title: Text(data['businessName'] +
                                              ' | ' +
                                              data['service'] +
                                              ' | ' +
                                              data['region']),
                                          subtitle: Text(
                                            'pricing: ' +
                                                '\$' +
                                                data['pricing'].toString() +
                                                ' | ' +
                                                'rating: ' +
                                                data['rating'].toString() +
                                                "/5",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                    ],
                                  );
                                },
                              );
                            } else {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 16),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Card(
                                    color: Colors.red[300],
                                    margin: EdgeInsets.all(16),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'No reviews found for this category',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
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
                      ))
                    ],
                  )),
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

  void aggregateData(List<Object?> snapshots) {
    double pricingSum = 0;
    double ratingSum = 0;
    int count = snapshots.length;

    if (count != 0) {
      snapshots.forEach((snapshot) {
        if (snapshot is Map<String, dynamic>) {
          if (selectedService != 'All Services') {
            double pricing = snapshot['pricing'];
            pricingSum += pricing;
          }
          int rating = snapshot['rating'];
          ratingSum += rating;
        }
      });
      if (selectedService != 'All Services') {
        double average = pricingSum / count;
        averagePriceNotifier.value = average.toStringAsFixed(2);
      } else {
        averagePriceNotifier.value = 'N/A';
      }
      double averageRating = ratingSum / count;
      averageRatingNotifier.value = averageRating.toStringAsFixed(2);
    } else {
      averagePriceNotifier.value = 'NoRecords';
      averageRatingNotifier.value = 'NoRecords';
    }
  }
}
