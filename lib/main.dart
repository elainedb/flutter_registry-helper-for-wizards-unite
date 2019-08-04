import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/bottom_bar_nav.dart';
import 'package:registry_helper_for_wu/signin.dart';
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
final Color backgroundColorUnselected = Color(0x88371F21);
final Color backgroundColorBottomBar = Color(0xFFf4c862);
final MaterialColor backgroundMaterialColor = MaterialColor(backgroundColorInt, backgroundColorMap);

void main() {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Registry Helper for Wizards Unite',
      theme: ThemeData(primarySwatch: backgroundMaterialColor),
      home: MyHomePage(title: 'Registry Helper for Wizards Unite', observer: observer),
      navigatorObservers: <NavigatorObserver>[observer],
//      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.observer}) : super(key: key);

  final String title;
  final NavigatorObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState(observer);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.observer);

  final FirebaseAnalyticsObserver observer;
  String _userId = "";
  bool _isUserAnonymous;
  bool _isRegistryLoading = false;
  bool _isUserDataLoading = false;

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

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        if (_isRegistryLoading || _isUserDataLoading) {
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
        return BottomBarNavWidget(_registry, observer);
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
        _isUserAnonymous = user.isAnonymous;
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
    setState(() { _isRegistryLoading = true; });

    var registryString = await rootBundle.loadString('json/registry.json');
    await prefs.setString('registry', registryString);
    setState(() {
      Map registryMap = jsonDecode(registryString);
      _registry = Registry.fromJson(registryMap) ?? null;
      _isRegistryLoading = false;
    });

    _initUserData(_userId, prefs);
  }

  _initUserData(String userId, SharedPreferences prefs) {
    setState(() { _isUserDataLoading = true; });
    var registryIds = getAllFoundablesIds(_registry);

    if (!_isUserAnonymous) {
      Firestore.instance.collection('userData').document(userId).get().then((snapshot) async {
        if (!snapshot.exists) {
          _addUserData(registryIds, userId);
        } else {
          // don't do it because too many queries :o
          // AND useless (for now)
          // TODO figure out how to do it later
          // TODO manage registry update -> fail to show user data for local registry -> add new data (show message?)
          // _checkAndAddNewUserKeys(snapshot, registryIds, userId);
          setState(() { _isUserDataLoading = false; });
        }
      });
    } else {
      Firestore.instance.collection('userData').document(userId).get().then((snapshot) async {
        if (!snapshot.exists) {
          var userDataString = prefs.getString('userData');
          if (userDataString == null) {
            _initAnonymousData(registryIds);
          } else {
            setState(() { _isUserDataLoading = false; });
          }
        } else {
          _migrateAnonymous(snapshot.data, userId);
        }
      });
//      _isUserLoading = false;
    }
  }

  _addUserData(List<String> ids, String userId) {
    Map<String, dynamic> map = Map();

    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    Firestore.instance.collection('userData').document(userId).setData(map, merge: true).then((_) {
      setState(() { _isUserDataLoading = false; });
    });
  }

  _checkAndAddNewUserKeys(DocumentSnapshot snapshot, List<String> registryIds, String userId) {
    var userIds = List<String>();
    var toAddIds = List<String>();
    snapshot.data.forEach((id, value) {
      userIds.add(id);
    });

    registryIds.forEach((registryId) {
      if (!userIds.contains(registryId)) {
        toAddIds.add(registryId);
      }
    });

    if (toAddIds.isNotEmpty) {
      _addUserData(toAddIds, userId);
    } else {
      setState(() {
        _isUserDataLoading = false;
      });
    }
  }

  _migrateAnonymous(Map<String, dynamic> data, String userId) async {
    // TODO temp code -> delete when all anonymous were migrated
    saveUserDataToPrefs(UserData(data)).then((value) {
      Firestore.instance.collection('userData').document(userId).delete();
      setState(() { _isUserDataLoading = false; });
    });
  }

  _initAnonymousData(List<String> ids) async {
    Map<String, dynamic> map = Map();
    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    saveUserDataToPrefs(UserData(map)).then((value) {
      setState(() { _isUserDataLoading = false; });
    });
  }
}
