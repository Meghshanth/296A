import 'package:flutter/material.dart';

class Discussion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disussions',
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
                'Welcome To Discussion!',
                textAlign: TextAlign
                    .center, // Align the text within the center of the card
              ),
              SizedBox(height: 10),
              Card(
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(60),
                    onTap: () {
                      debugPrint('Card tapped.');
                    },
                    child: ListTile(
                        leading: Icon(Icons.reviews_outlined, color: Colors.blue[600]),
                        title: Text(
                          'Reviews',
                          textAlign: TextAlign
                              .center, // Align the text within the center of the card
                        ),
                        subtitle: Text(
                          'Want to check pricing on services? See reviews? ',
                          textAlign: TextAlign.center,
                        ))),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      debugPrint('Card tapped.');
                    },
                    child: ListTile(
                      leading: Icon(Icons.help_center_outlined,  color: Colors.blue[600]),
                      title: Text(
                        'Discussions',
                        textAlign: TextAlign
                            .center, // Align the text within the center of the card
                      ),
                      subtitle: Text(
                        'Have a question? Ask fellow Broncos for help!',
                        textAlign: TextAlign.center,
                      ),
                    )),
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
