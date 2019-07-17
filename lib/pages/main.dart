import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/pages/settings.dart';
import 'package:registry_helper_for_wu/widgets/registry.dart';
import 'package:registry_helper_for_wu/widgets/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registry Helper for Wizards Unite',
      home: MyHomePage(title: 'Registry Helper for Wizards Unite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _userId = "";
  bool _isDataLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      _manageFirebaseUser(user);
    });

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _manageFirebaseUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingsIcon;
    if (_userId.isNotEmpty && _userId != "null" && !_isDataLoading) {
      settingsIcon = <Widget>[
        IconButton(
          onPressed: () => _pushPage(context, SettingsPage()),
          icon: const Icon(Icons.settings),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: settingsIcon,
      ),
      body: Builder(builder: (BuildContext context) {
        if (_isDataLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        switch (_userId) {
          case "":
            return Center(
              child: Text("Loading..."),
            );
          case "null":
            return SignInWidget();
        }
        return RegistryWidget();
      }),
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void _manageFirebaseUser(FirebaseUser user) {
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _downloadRegistryData();
      });
    } else {
      setState(() {
        _userId = "null";
      });
    }
  }

  _downloadRegistryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int localVersion = prefs.getInt('registryVersion') ?? -1;
    int firestoreVersion = 0;

    await Firestore.instance.collection("settings").document("version").get().then((snapshot) {
      firestoreVersion = snapshot.data["registry"];
    });

    if (firestoreVersion > localVersion) {
      _getRegistry(prefs, firestoreVersion);
      setState(() {
        _isDataLoading = true;
      });
    }
  }

  _getRegistry(SharedPreferences prefs, int firestoreVersion) {
    Firestore.instance.collection("registryData").snapshots().forEach((snapshot) async {
      if (snapshot != null) {
        List<Chapter> chapterList = List();
        for (var chapter in snapshot.documents) {
          String chapterId = chapter.documentID;
          String chapterName = chapter.data["name_en"];
          List<Page> pageList = List();
          await chapter.reference.collection("pages").getDocuments().then((pages) async {
            if (pages != null) {
              for (var page in pages.documents) {
                String pageId = page.documentID;
                String pageName = page.data["name_en"];
                List<Foundable> foundableList = List();
                await page.reference.collection("foundables").getDocuments().then((foundables) {
                  if (foundables != null) {
                    for (var foundable in foundables.documents) {
                      foundableList.add(Foundable(foundable.documentID, foundable.data['name_en'], foundable.data['frag_req1'], foundable.data['frag_req2'],
                          foundable.data['frag_req3'], foundable.data['frag_req4']));
                    }
                  }
                });
                print("pageList.add(Page(pageId, pageName, foundableList));");
                pageList.add(Page(pageId, pageName, foundableList));
              }
            }
          });
          print("chapterList.add(Chapter(chapterId, chapterName, pageList));");
          chapterList.add(Chapter(chapterId, chapterName, pageList));
        }
        print("registry = Registry(chapterList);");
        setState(() {
          print("setstate");
          _isDataLoading = false;
        });

        await prefs.setInt('registryVersion', firestoreVersion);
        await prefs.setString('registry', jsonEncode(Registry(chapterList)));
      }
    });
  }
}
