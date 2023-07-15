import 'package:flutter/material.dart';
import 'package:pfsi/authPages/signup.dart';
import 'package:pfsi/discussionPages/discussionAdd.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfsi/discussionPages/discussionView.dart';

void main() => runApp(const DiscussionPage());

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({Key? key}) : super(key: key);
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage>
    with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final int _perPage = 20; // Number of documents to fetch per page
  // DocumentSnapshot? _lastDocument; // Last fetched document for pagination
  String _selectedOption = 'All discussions';
  final ValueNotifier<String> _selectedOptionNotifier =
      ValueNotifier<String>('All discussions');
  @override
  void dispose() {
    _selectedOptionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? uuid = user?.uid;

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

    Stream<QuerySnapshot> _fetchData() {
      Query query = _firestore.collection('discussion_list').orderBy(
          'dateTimestamp',
          descending: true); // Order by a field for pagination
      // .limit(_perPage); // Limit the number of documents per page
      if (_selectedOption == 'Your discussions') {
        query = query.where('userid', isEqualTo: uuid);
      }

      return query.snapshots();
    }

    return Scaffold(
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
      // body: Padding(
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     children: [
      //       SizedBox(height: 10),
      //       DropdownButton<String>(
      //         value: _selectedOption,
      //         onChanged: (String? newValue) {
      //           setState(() {
      //             _selectedOption = newValue!;
      //           });
      //           _selectedOptionNotifier.value = newValue!;
      //         },
      //         items: <String>[
      //           'All discussions',
      //           'Your discussions',
      //         ].map<DropdownMenuItem<String>>((String value) {
      //           return DropdownMenuItem<String>(
      //             value: value,
      //             child: Text(value),
      //           );
      //         }).toList(),
      //       ),
      //       Flexible(
      //         child: ValueListenableBuilder<String>(
      //           valueListenable: _selectedOptionNotifier,
      //           builder: (context, selectedOption, child) {
      //             return StreamBuilder<QuerySnapshot>(
      //               stream: _fetchData(),
      //               builder: (context, snapshot) {
      //                 if (snapshot.hasData) {
      //                   final documents = snapshot.data!.docs;
      //                   return ListView.builder(
      //                     itemCount: documents.length,
      //                     itemBuilder: (context, index) {
      //                       final data =
      //                           documents[index].data() as Map<String, dynamic>;
      //                       return Column(
      //                         children: [
      //                           InkWell(
      //                             splashColor: Colors.red,
      //                             hoverColor: Colors.red[200],
      //                             onTap: () {
      //                               Navigator.push(
      //                                 context,
      //                                 MaterialPageRoute(
      //                                   builder: (context) => DiscussionView(
      //                                     documents[index].id,
      //                                   ),
      //                                 ),
      //                               );
      //                             },
      //                             child: ListTile(
      //                               title: Text(data['topic']),
      //                             ),
      //                           ),
      //                           Divider(),
      //                         ],
      //                       );
      //                     },
      //                   );
      //                 } else if (snapshot.hasError) {
      //                   return Text('Error: ${snapshot.error}');
      //                 } else {
      //                   return CircularProgressIndicator();
      //                 }
      //               },
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Text('This is discussions page'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => DiscussionAdd()),
          // );
        },
        backgroundColor: Colors.red[300],
        tooltip: 'Add a New Discussion',
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
