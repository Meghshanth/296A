import 'package:flutter/material.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/discussionPages/discussion.dart';
import 'package:pfsi/reviewPages/review.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommonNavigation extends StatefulWidget {
  @override
  _CommonNavigationState createState() => _CommonNavigationState();
}

class _CommonNavigationState extends State<CommonNavigation> {
  int _currentIndex = 0;
  static const List<String> _titles = ['Reviews', 'Discussions'];
  final List<Widget> _pages = [
    // Add your pages here
    Review(),
    Discussion(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.red,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_2_outlined),
            label: 'Discussions',
          ),
        ],
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 1'),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 2'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CommonNavigation(),
  ));
}
