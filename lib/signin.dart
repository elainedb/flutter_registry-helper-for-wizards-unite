import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:registry_helper_for_wu/widgets/version.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Registry Helper for Wizards Unite!\n\nIn order to backup and synchronize your data accross devices, please sign in.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                _signInWithGoogle();
              },
              child: const Text('Sign in with Google'),
            ),
          ),
          Container(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'If you wish to try out first, you can sign in anonymously.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 100.0),
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                _signInAnonymous();
              },
              child: const Text('Anonymous sign in'),
            ),
          ),
          Center(child: VersionWidget()),
        ],
      );
    });
  }

  void _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  void _signInAnonymous() async {
    await _auth.signInAnonymously();
  }
}
