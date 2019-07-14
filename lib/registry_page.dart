import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistryPage extends StatefulWidget {
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => RegistryPageState();
}

class RegistryPageState extends State<RegistryPage> {
  String _userId;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        _userId = user.uid;
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
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter something',
              ),
              onSubmitted: (text) => {_submit(_userId, text)},
            ),
            RaisedButton(
              child: const Text('Init Firebase'),
              onPressed: () => _initUserData(_userId),
            )
          ],
        );
      }),
    );
  }
}

_submit(String userId, String text) {
  Firestore.instance.collection('userData').document(userId).setData({'text': text});
}

_initUserData(String userId) {
  List<String> ids = ["hh_1", "hh_2", "hh_3", "hh_4", "hh_5", "pp_1", "pp_2", "pp_3", "pp_4", "pp_5"];

  for (var id in ids) {
    Firestore.instance.collection('userData').document(userId).setData({id: {'count': 0, 'level': 1}}, merge: true);
  }
}

String _handleSignIn() {
  /*bool loggedIn = false;
  var userUid;
  FirebaseAuth.instance.currentUser().then((user) {
    if (user != null) {
      userUid = user.uid;
      loggedIn = true;
    }
    print('trsting $loggedIn');

  });*/

  return "";
}
