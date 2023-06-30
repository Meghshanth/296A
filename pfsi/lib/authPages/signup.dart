import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pfsi/commonNavigation/commonNavigation.dart';

import '../homePages/home.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signup(BuildContext context) async {
    try {
      bool validPassword = isValidPassword(passwordController.text);
      bool validEmail = isValidEmail(emailController.text);

      if (validEmail && validPassword) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          displaySnackBar(context,
              'Account created. Email verification sent to ${user.email}');
        }
        // Signup successful, navigate to the next screen or perform any other actions
        print('User registered: ${userCredential.user}');
      } else {
        if (!validPassword) {
          // Invalid password
          displaySnackBar(context,
              'Invalid password. Password should be atlease 8 characters long');
        }
        if (!validEmail) {
          // Invalid email
          displaySnackBar(context,
              'Invalid email. Please provide a valid @scu.edu email address.');
        }
      }
    } catch (e) {
      // Handle signup errors
      displaySnackBar(
          context, 'email address is already in use, try signing in.');
      print('Signup failed: $e');
    }
  }

  void _signin(BuildContext context) async {
    try {
      bool validPassword = isValidPassword(passwordController.text);
      bool validEmail = isValidEmail(emailController.text);

      if (validEmail && validPassword) {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (!user.emailVerified) {
            displaySnackBar(
                context, 'Email not verified, verifiy email before sign in');
          } else {
            await secureStorage.write(
                key: 'user_token', value: userCredential.user?.uid);
            // Navigate to the desired component/screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CommonNavigation()),
            );
          }
        }

        // Signup successful, navigate to the next screen or perform any other actions
        print('User registered: ${userCredential.user}');
      } else {
        if (!validPassword) {
          // Invalid password
          displaySnackBar(context,
              'Invalid password. Password should be atlease 8 characters long');
        }
        if (!validEmail) {
          // Invalid email
          displaySnackBar(context,
              'Invalid email. Please provide a valid @scu.edu email address.');
        }
      }
    } catch (e) {
      // Handle signup errors
      displaySnackBar(context, 'Invalid email or password.');
      print('Signup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bronco Help', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red[300],),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () => _signin(context),
                child: Text('Sign In'),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () => _signup(context),
                child: Text('Sign Up'),
              )
            ])
          ],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    RegExp regex = RegExp(r"^[^\s@]+@scu\.edu$");
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    if (password.length > 7) {
      return true;
    }
    return false;
  }

  void displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
