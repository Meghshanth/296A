import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';
import 'package:pfsi/homePages/home.dart';
import 'firebase_options.dart';
import 'authPages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void checkUserLoggedIn() async {
      try {
         final User? user = FirebaseAuth.instance.currentUser;
          String? uuid = user?.uid;
        if (uuid != null) {
         

          // User token exists, proceed with automatic sign-in
          print('User token found: $uuid');

  

          // Navigate to the desired component/screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CommonNavigation()),
          );
        } else {
          // User token does not exist, prompt for sign-in
          print('User token not found');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );

          // Navigator.pushReplacement(
          //   // Temp for Dev
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeScreen()),
          // );
        }
      } catch (e) {
        print(e);
        // Navigator.pushReplacement(
        //   // Temp for Dev
        //   context,
        //   MaterialPageRoute(builder: (context) => HomeScreen()),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      }
    }

    Timer(Duration(seconds: 2), () {
      checkUserLoggedIn();
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Go',
              style: TextStyle(
                fontSize: 90,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = Colors.red,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Broncos!',
              style: TextStyle(
                fontSize: 90,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bronco Help',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: HomePage(),
      // home: CommonNavigation(), //DEV
    );
  }
}
