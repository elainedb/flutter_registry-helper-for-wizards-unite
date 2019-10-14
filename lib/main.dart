import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_bar_nav.dart';
import 'data/data.dart';
import 'resources/values/app_colors.dart';
import 'resources/values/app_styles.dart';
import 'signin.dart';
import 'widgets/loading.dart';

void main() {
  Crashlytics.instance.enableInDevMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  //override the red screen of death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
    return Scaffold(
      body: Padding(
        padding: AppStyles.miniInsets,
        child: const Center(
          child: Text(
            'An unexpected error occurred.',
            style: AppStyles.largeText,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundMaterialColor,
    );
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
      theme: AppStyles.appThemeData,
      home: MyHomePage(title: 'Registry Helper for Wizards Unite', observer: observer, analytics: analytics),
      navigatorObservers: <NavigatorObserver>[observer],
//      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.observer, this.analytics}) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState(observer, analytics);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.observer, this.analytics);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  String _userId = "";
  bool _isUserAnonymous;
  bool _isRegistryLoading;
  bool _isUserDataLoading;

  Registry _registry;

  @override
  void initState() {
    super.initState();

    _isRegistryLoading = false;
    _isUserDataLoading = false;

    FirebaseAuth.instance.currentUser().then((user) {
      _manageFirebaseUser(user);
    });

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _manageFirebaseUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      if(_isRegistryLoading || _isUserDataLoading) {
        return Center(child: CircularProgressIndicator(backgroundColor: AppColors.progressIndicatorColor,),);
      }

      switch(_userId) {
        case "":
          return LoadingWidget();
        case "null":
          observer.analytics.setCurrentScreen(screenName: "SignInPage",);
          return SignInWidget(analytics);
      }
      return BottomBarNavWidget(_registry, observer, analytics);
    }), backgroundColor: AppColors.backgroundMaterialColor,);
  }

  void _manageFirebaseUser(FirebaseUser user) {
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _isUserAnonymous = user.isAnonymous;
        _setUserId();
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
    setState(() {
      _isRegistryLoading = true;
    });

    var registryString = await rootBundle.loadString('assets/json/registry.json');
    await prefs.setString('registry', registryString);
    setState(() {
      Map registryMap = jsonDecode(registryString);
      _registry = Registry.fromJson(registryMap) ?? null;
      _isRegistryLoading = false;
    });

    _initUserData(_userId, prefs);
  }

  _initUserData(String userId, SharedPreferences prefs) {
    setState(() {
      _isUserDataLoading = true;
    });
    var registryIds = getAllFoundablesIds(_registry);

    if (!_isUserAnonymous) {
      Firestore.instance.collection('userData').document(userId).get().then((snapshot) async {
        if (!snapshot.exists) {
          _addUserDataConnected(registryIds, userId);
        } else {
          _checkAndAddNewUserKeysConnected(snapshot, registryIds, userId);
          setState(() {
            _isUserDataLoading = false;
          });
        }
      }).catchError((error) {
          setState(() {
            _userId = "null";
            _isUserDataLoading = false;
          });
      });
    } else {
      Firestore.instance.collection('userData').document(userId).get().then((snapshot) async {
        if (!snapshot.exists) {
          var userDataString = prefs.getString('userData');
          if (userDataString == null) {
            _initAnonymousData(registryIds);
          } else {
            _checkAndAddNewUserKeysAnonymous(userDataString, registryIds);
            setState(() {
              _isUserDataLoading = false;
            });
          }
        } else {
          _migrateAnonymous(snapshot.data, userId);
        }
      });
//      _isUserLoading = false;
    }
  }

  _checkAndAddNewUserKeysConnected(DocumentSnapshot snapshot, List<String> registryIds, String userId) {
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
      _addUserDataConnected(toAddIds, userId);
    } else {
      setState(() {
        _isUserDataLoading = false;
      });
    }
  }

  _addUserDataConnected(List<String> ids, String userId) {
    Map<String, dynamic> map = Map();

    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    Firestore.instance.collection('userData').document(userId).setData(map, merge: true).then((_) {
      setState(() {
        _isUserDataLoading = false;
      });
    });
  }

  _checkAndAddNewUserKeysAnonymous(String userDataString, List<String> registryIds) {
    var userIds = List<String>();
    var toAddIds = List<String>();

    Map map = jsonDecode(userDataString);
    UserData oldUserData = UserData.fromJson(map);

    oldUserData.fragmentDataList.forEach((id, value) {
      userIds.add(id);
    });

    registryIds.forEach((registryId) {
      if (!userIds.contains(registryId)) {
        toAddIds.add(registryId);
      }
    });

    if (toAddIds.isNotEmpty) {
      _addUserDataAnonymous(toAddIds, oldUserData);
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
      setState(() {
        _isUserDataLoading = false;
      });
    });
  }

  _initAnonymousData(List<String> ids) async {
    Map<String, dynamic> map = Map();
    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    saveUserDataToPrefs(UserData(map)).then((value) {
      setState(() {
        _isUserDataLoading = false;
      });
    });
  }

  _addUserDataAnonymous(List<String> newIds, UserData oldUserData) {
    Map<String, dynamic> map = oldUserData.fragmentDataList;
    for (var id in newIds) {
      map[id] = {'count': 0, 'level': 1};
    }

    saveUserDataToPrefs(UserData(map)).then((value) {
      setState(() {
        _isUserDataLoading = false;
      });
    });
  }

  _setUserId() async {
    await analytics.setUserId(_userId);
  }
}
