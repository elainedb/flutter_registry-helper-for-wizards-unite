import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:registry_helper_for_wu/widgets/version.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SettingsPage extends StatefulWidget {
  final FirebaseAnalytics _analytics;
  SettingsPage(this._analytics);

  @override
  State<StatefulWidget> createState() => SettingsPageState(_analytics);
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAnalytics _analytics;
  SettingsPageState(this._analytics);

  String _userEmail = "";

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userEmail = user.email;
          if (user.isAnonymous) {
            _userEmail = "Anonymous";
          }
        });
      }
    });

    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Logged in as $_userEmail", style: TextStyle(color: Colors.white),),
        Container(height: 24,),
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
    _sendLogoutEvent();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  _sendLogoutEvent() async {
    await _analytics.logEvent(
      name: 'click_logout',
    );
  }
}
