import 'package:flutter/material.dart';

class Discussion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                'Welcome To Discussion!',
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
