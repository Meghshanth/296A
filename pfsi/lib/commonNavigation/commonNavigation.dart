import 'package:flutter/material.dart';
import 'package:pfsi/discussionPages/discussion.dart';
import 'package:pfsi/reviewPages/review.dart';

class CommonNavigation extends StatefulWidget {
  @override
  _CommonNavigationState createState() => _CommonNavigationState();
}

class _CommonNavigationState extends State<CommonNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    // Add your pages here
    Review(),
    DiscussionPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

void main() {
  runApp(
    CommonNavigation(),
  );
}
