import 'package:flutter/material.dart';

class DiscussionAdd extends StatelessWidget {
  TextEditingController _questionController = TextEditingController();
  TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your Topic',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _questionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your question',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Get the entered question
                String question = _questionController.text;
                String topic = _topicController.text;

                // Submit button logic here
                print('Submitted question: $question $topic');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
