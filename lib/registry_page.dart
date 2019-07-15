import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Foundable {
  final int fragmentRequirementStandard;
  final int fragmentRequirementBronze;
  final int fragmentRequirementSilver;
  final int fragmentRequirementGold;
  final String name;

  Foundable(this.fragmentRequirementStandard, this.fragmentRequirementBronze,
      this.fragmentRequirementSilver, this.fragmentRequirementGold, this.name);
}

class RegistryPage extends StatefulWidget {
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => RegistryPageState();
}

class RegistryPageState extends State<RegistryPage> {
  String _userId;
  Map<String, Foundable> _registryData = Map();

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        _userId = user.uid;
      }
    });

//    Firestore.instance.collection('registryData').getDocuments().then((snapshot) {
//      if (snapshot != null) {
//        for (var doc in snapshot.documents)
//        print(doc);
//      }
//    });

    Firestore.instance
        .collection("registryData")
        .document("cmc")
        .collection("pages")
        .document("hh")
        .collection("foundables")
        .getDocuments()
        .then((snapshot) {
      if (snapshot != null) {
        for (var doc in snapshot.documents) {
          var id = doc.documentID;
          var data = doc.data;
          _registryData[id] = Foundable(data["frag_req1"], data["frag_req2"],
              data["frag_req3"], data["frag_req4"], data["name_en"]);
        }
        print("_registryData = $_registryData");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('userData')
                .document(_userId)
                .snapshots(),
            builder: (context, snapshot) {
              return ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Text(_registryData['hh_1'] != null
                              ? _registryData['hh_1'].name
                              : "loading")),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                              text: (snapshot.hasData && snapshot.data != null)
                                  ? snapshot.data['hh_1']['count'].toString()
                                  : "loading"),
                          onSubmitted: (newText) => {_submit2(_userId, 'hh_1', newText)},
                        ),
                      ),
                      Text(
                          "/${_registryData['hh_1'] != null ? _registryData['hh_1'].fragmentRequirementStandard : "loading"}")
                    ],
                  ),
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
            });
      }),
    );
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

_initUserData(String userId) {
  List<String> ids = [
    "hh_1",
    "hh_2",
    "hh_3",
    "hh_4",
    "hh_5",
    "pp_1",
    "pp_2",
    "pp_3",
    "pp_4",
    "pp_5"
  ];

  for (var id in ids) {
    Firestore.instance.collection('userData').document(userId).setData({
      id: {'count': 0, 'level': 1}
    }, merge: true);
  }
}

_submit(String userId, String text) {
  Firestore.instance
      .collection('userData')
      .document(userId)
      .setData({'text': text});
}

_submit2(String userId, String foundableId, String newValue) {
  Firestore.instance
      .collection('userData')
      .document(userId)
      .setData({foundableId: {'count': int.parse(newValue)}}, merge: true);
}