import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/reviewPages/reviewAdd.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<Review> with TickerProviderStateMixin {
  String _selectedReviewType = 'All reviews';
  final ValueNotifier<String> _selectedReviewTypeNotifier =
      ValueNotifier<String>('All reviews');

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
      body: Column(
        mainAxisAlignment: _selectedReviewType == 'Your reviews'
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          Align(
            alignment: Alignment.center,
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedReviewTypeNotifier,
              builder: (context, value, child) {
                return DropdownButton<String>(
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
          ),
        ],
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
