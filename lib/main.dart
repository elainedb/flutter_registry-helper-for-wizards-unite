import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/pages/settings.dart';
import 'package:registry_helper_for_wu/widgets/registry.dart';
import 'package:registry_helper_for_wu/widgets/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<int, Color> backgroundColorMap = {
  50: Color.fromRGBO(55, 31, 33, .1),
  100: Color.fromRGBO(55, 31, 33, .2),
  200: Color.fromRGBO(55, 31, 33, .3),
  300: Color.fromRGBO(55, 31, 33, .4),
  400: Color.fromRGBO(55, 31, 33, .5),
  500: Color.fromRGBO(55, 31, 33, .6),
  600: Color.fromRGBO(55, 31, 33, .7),
  700: Color.fromRGBO(55, 31, 33, .8),
  800: Color.fromRGBO(55, 31, 33, .9),
  900: Color.fromRGBO(55, 31, 33, 1),
};

final backgroundColorInt = 0xFF371F21;
final Color backgroundColor = Color(backgroundColorInt);
final MaterialColor backgroundMaterialColor = MaterialColor(backgroundColorInt, backgroundColorMap);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registry Helper for Wizards Unite',
      theme: ThemeData(primarySwatch: backgroundMaterialColor),
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
  bool _isRegistryLoading = false;
  bool _isUserLoading = false;
  Registry _registry;

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
    if (_userId.isNotEmpty && _userId != "null" && !_isRegistryLoading && !_isUserLoading) {
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
        elevation: 0,
      ),
      body: Builder(builder: (BuildContext context) {
        if (_isRegistryLoading || _isUserLoading) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
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
        return RegistryWidget(_registry);
      }),
      backgroundColor: backgroundMaterialColor,
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
        _isRegistryLoading = true;
      });
    } else {
      _initUserData(_userId);
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
          _isRegistryLoading = false;
        });

        _registry = Registry(chapterList);
        await prefs.setInt('registryVersion', firestoreVersion);
        await prefs.setString('registry', jsonEncode(_registry));

        _initUserData(_userId);
      }
    });
  }

  _initUserData(String userId) {
    setState(() {
      _isUserLoading = true;
    });
    Firestore.instance.collection('userData').document(userId).get().then((snapshot) async {
      if (!snapshot.exists) {
        if (_registry == null) {
          await _getRegistryFromSharedPrefs();
        }
        List<String> ids = getAllFoundablesIds(_registry);

        Map<String, dynamic> map = Map();

        for (var id in ids) {
          map[id] = {'count': 0, 'level': 1};
        }

        Firestore.instance.collection('userData').document(userId).setData(map).then((_) {
          setState(() {
            _isUserLoading = false;
          });
        });
      } else {
        setState(() {
          _isUserLoading = false;
        });
      }
    });
  }

  _getRegistryFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var registryString = prefs.getString('registry') ?? "";
    if (registryString.isNotEmpty) {
      setState(() {
        Map registryMap = jsonDecode(registryString);
        _registry = Registry.fromJson(registryMap) ?? null;
      });
    }
  }
}
