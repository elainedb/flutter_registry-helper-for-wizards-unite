import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:registry_helper_for_wu/widgets/version.dart';

import '../main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SettingsPage extends StatefulWidget {
  final String title = 'Settings';
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: RaisedButton(
            onPressed: () => _firebaseSignOut(),
            child: Text("Sign Out"),
          ),
        ),
        Container(height: 24,),
        Center(child: VersionWidget()),
      ],
    );
  }

  Future<void> _firebaseSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
