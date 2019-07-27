import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/pages/locator.dart';
import 'package:registry_helper_for_wu/pages/helper.dart';
import 'package:registry_helper_for_wu/pages/my_registry.dart';
import 'package:registry_helper_for_wu/pages/settings.dart';
import 'package:registry_helper_for_wu/pages/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/data.dart';
import 'main.dart';

//https://www.wizardunite.com/2019/05/hpwu-foundables-and-traces.html
//https://github.com/hpwizardsunite-dev-contrib
//https://wizardsunitehub.info/foundables/

final cmcDark = const Color(0xFF3B748C); final cmcDarkStringHex = '#3B748C';
final cmcLight = const Color(0xFFB7DAEF); final cmcLightStringHex = '#B7DAEF';
final daDark = const Color(0xFF3A5C2A); final daDarkStringHex = '#3A5C2A';
final daLight = const Color(0xFFCCEF85); final daLightStringHex = '#CCEF85';
final hsDark = const Color(0xFF73442C); final hsDarkStringHex = '#73442C';
final hsLight = const Color(0xFFE6936C); final hsLightStringHex = '#E6936C';
final lohDark = const Color(0xFF646155); final lohDarkStringHex = '#646155';
final lohLight = const Color(0xFFE8E3C8); final lohLightStringHex = '#E8E3C8';
final momDark = const Color(0xFF513C2B); final momDarkStringHex = '#513C2B';
final momLight = const Color(0xFFE6AE61); final momLightStringHex = '#E6AE61';
final mDark = const Color(0xFF273675); final mDarkStringHex = '#273675';
final mLight = const Color(0xFF99B1F9); final mLightStringHex = '#99B1F9';
final mgsDark = const Color(0xFF875F04); final mgsDarkStringHex = '#875F04';
final mgsLight = const Color(0xFFE6C976); final mgsLightStringHex = '#E6C976';
final maDark = const Color(0xFF612231); final maDarkStringHex = '#612231';
final maLight = const Color(0xFFEF989A); final maLightStringHex = '#EF989A';
final wwwDark = const Color(0xFF13717E); final wwwDarkStringHex = '#13717E';
final wwwLight = const Color(0xFF72F9F9); final wwwLightStringHex = '#72F9F9';
final oDark = const Color(0xFF382463); final oDarkStringHex = '#382463';
final oLight = const Color(0xFFA77CE8); final oLightStringHex = '#A77CE8';

class BottomBarNavWidget extends StatefulWidget {
  final Registry _firebaseRegistry;
  final FirebaseAnalyticsObserver _observer;
  BottomBarNavWidget(this._firebaseRegistry, this._observer);

  @override
  State<StatefulWidget> createState() => BottomBarNavWidgetState(_firebaseRegistry, _observer);
}

class BottomBarNavWidgetState extends State<BottomBarNavWidget> {
  final Registry _firebaseRegistry;
  final FirebaseAnalyticsObserver _observer;
  BottomBarNavWidgetState(this._firebaseRegistry, this._observer);

  String _userId = "";
  Registry _registry;
  List<Widget> _widgetOptions = <Widget>[
    Text('Loading'),
    Text('Loading'),
    Text('Loading'),
    Text('Loading'),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _updateWidgets();
        });
      }
    });

    if (_firebaseRegistry != null) {
      setState(() {
        _registry = _firebaseRegistry;
        _updateWidgets();
      });
    } else {
      _getRegistryFromSharedPrefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build for _userId = $_userId');

    return Builder(builder: (BuildContext context) {
      if (_userId.isEmpty) {
        return Center(
          child: Text("Loading"),
        );
      }
      return Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              title: Text('Helper'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              title: Text('Charts'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              title: Text('My Registry'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
          selectedItemColor: backgroundColor,
          unselectedItemColor: backgroundColorUnselected,
          backgroundColor: backgroundColorBottomBar,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        backgroundColor: backgroundColor,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _observer.analytics.setCurrentScreen(
        screenName: 'Tab$_selectedIndex',
      );
    });
  }

  _updateWidgets() {
    setState(() {
      _widgetOptions = <Widget>[
        HelperPage(_registry),
        ChartsPage(_registry),
        MyRegistryPage(_registry),
        SettingsPage(),
      ];
    });
  }

  _getRegistryFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var registryString = prefs.getString('registry') ?? "";
    if (registryString.isNotEmpty) {
      setState(() {
        Map registryMap = jsonDecode(registryString);
        _registry = Registry.fromJson(registryMap) ?? null;
        _updateWidgets();
      });
    }
  }
}
