import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingsPage extends StatefulWidget {
  final String title = 'Settings';
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: RaisedButton(
            onPressed: () => _signOut(),
            child: Text("Sign Out"),
          ),
        );
      }),
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }
}
