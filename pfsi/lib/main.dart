import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pfsi/homePages/home.dart';
import 'firebase_options.dart';
import 'authPages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
      String? userToken = await secureStorage.read(key: 'user_token');
      try {
        if (userToken != null) {
          // User token exists, proceed with automatic sign-in
          print('User token found: $userToken');

          // Authenticate the user using the saved token
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCustomToken(userToken);

          // Navigate to the desired component/screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // User token does not exist, prompt for sign-in
          print('User token not found');
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => SignupPage()),
          // );

          Navigator.pushReplacement(
            // Temp for Dev
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } catch (e) {
        Navigator.pushReplacement(
          // Temp for Dev
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => SignupPage()),
        // );
      }
    }

    checkUserLoggedIn();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Add functionality for the button
              },
              child: Text('Button'),
            ),
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
      title: 'Flutter Demo',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
