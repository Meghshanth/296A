import 'package:flutter/material.dart';

class Review extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
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
                'Welcome To Review!',
                textAlign: TextAlign
                    .center, // Align the text within the center of the card
              ),
            ],
          ),
        ),
      ),
    );
  }
}
