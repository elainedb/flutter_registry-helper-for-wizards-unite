import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registry_helper_for_wu/pages/settings.dart';
import 'package:registry_helper_for_wu/widgets/registry.dart';
import 'package:registry_helper_for_wu/widgets/signin.dart';

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
    if (_userId.isNotEmpty && _userId != "null") {
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
      });
    } else {
      setState(() {
        _userId = "null";
      });
    }
  }
}
