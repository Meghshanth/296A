import 'package:flutter/material.dart';
import 'package:pfsi/discussionPages/discussionAdd.dart';

void main() => runApp(const Discussion());

class Discussion extends StatefulWidget {
  const Discussion({Key? key}) : super(key: key);
  @override
  _DiscussionState createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  var theme = ValueNotifier(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Flutter Speed Dial Example';
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: theme,
        builder: (context, value, child) => MaterialApp(
              title: appTitle,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
                useMaterial3: true,
              ),
              home: DiscussionPage(),
              debugShowCheckedModeBanner: false,
            ));
  }
}

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({Key? key}) : super(key: key);
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage>
    with TickerProviderStateMixin {
  var isDialOpen = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(),
                ),
              )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacement(
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
