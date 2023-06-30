import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                'Welcome Bronco!',
                textAlign: TextAlign
                    .center, // Align the text within the center of the card
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: Text(
                    'Reviews',
                    textAlign: TextAlign
                        .center, // Align the text within the center of the card
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: Text(
                    'Discussions',
                    textAlign: TextAlign
                        .center, // Align the text within the center of the card
                  ),
                  subtitle: Text(
                    'Have a question? Ask fellow Broncos for help!',
                    textAlign: TextAlign.center,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
