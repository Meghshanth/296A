import 'package:flutter/material.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/discussionPages/discussionAdd.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const DiscussionPage());

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({Key? key}) : super(key: key);
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage>
    with TickerProviderStateMixin {
  var isDialOpen = ValueNotifier<bool>(false);
  String _selectedOption = 'All discussions';
  @override
  Widget build(BuildContext context) {
    void logout() async {
      try {
        await FirebaseAuth.instance.signOut();
        // Perform any additional actions after logout
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      } catch (e) {
        // Handle logout errors
        print('Logout failed: $e');
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Discussion',
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
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      items: <String>[
                        'All discussions',
                        'Your discussions',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiscussionAdd()),
              );
              // Add your onPressed code here!
            },
            backgroundColor: Colors.red[300],
            tooltip: 'Add Discussion',
            child: const Icon(Icons.create_outlined),
          )),
    );
  }
}
