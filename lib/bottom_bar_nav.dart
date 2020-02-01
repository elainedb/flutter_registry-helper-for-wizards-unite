import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/data.dart';
import 'pages/helper.dart';
import 'pages/my_registry.dart';
import 'pages/settings.dart';
import 'pages/charts.dart';
import 'resources/values/app_colors.dart';
import 'utils/fanalytics.dart';
import 'widgets/loading.dart';

//https://www.wizardunite.com/2019/05/hpwu-foundables-and-traces.html
//https://github.com/hpwizardsunite-dev-contrib
//https://wizardsunitehub.info/foundables/

class BottomBarNavWidget extends StatefulWidget {
  final Registry _firebaseRegistry;
  BottomBarNavWidget(this._firebaseRegistry);

  @override
  State<StatefulWidget> createState() => BottomBarNavWidgetState(_firebaseRegistry);
}

class BottomBarNavWidgetState extends State<BottomBarNavWidget> {
  final Registry _jsonRegistry;
  BottomBarNavWidgetState(this._jsonRegistry);

  String _shortcut = "";
  String _sortValue = "";
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

    if (_jsonRegistry != null) {
      setState(() {
        _registry = _jsonRegistry;
        _updateWidgets();
      });
    } else {
      _getRegistryFromSharedPrefs();
    }

    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      setState(() {
        if (shortcutType != null) _shortcut = shortcutType;
        switch (_shortcut) {
          case 'helper_low':
            _selectedIndex = 1;
            _sortValue = "Low/Medium (no beam)";
            break;
          case 'helper_challenges':
            _selectedIndex = 1;
            _sortValue = "Wizarding Challenges rewards";
            break;
          case 'my_registry':
            _selectedIndex = 0;
            break;
          case 'charts':
            _selectedIndex = 2;
            break;
        }
        _updateWidgets();
      }
      );
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'helper_low',
        localizedTitle: 'Helper - Low/Medium',
        icon: 'ic_wild',
      ),
      const ShortcutItem(
        type: 'helper_challenges',
        localizedTitle: 'Helper - Challenges',
        icon: 'ic_challenges',
      ),
      const ShortcutItem(
        type: 'charts',
        localizedTitle: 'Charts',
        icon: 'ic_charts',
      ),
      const ShortcutItem(
        type: 'my_registry',
        localizedTitle: 'My Registry',
        icon: 'ic_folder',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    print('build for _userId = $_userId, selectedIndex = $_selectedIndex, sortValue = $_sortValue, shortcut = $_shortcut');

    return Builder(builder: (BuildContext context) {
      if (_userId.isEmpty) {
        return LoadingWidget();
      }
      return Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              title: Text('My Registry'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              title: Text('Helper'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              title: Text('Charts'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
          selectedItemColor: AppColors.backgroundColor,
          unselectedItemColor: AppColors.backgroundColorUnselected,
          backgroundColor: AppColors.backgroundColorBottomBar,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        backgroundColor: AppColors.backgroundColor,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      String pageName = "";
      switch(index) {
        case 0:
          pageName = "MyRegistryPage";
          break;
        case 1:
          pageName = "HelperPage_MissingFoundables";
          break;
        case 2:
          pageName = "ChartsPage";
          break;
        case 3:
          pageName = "SettingsPage";
          break;
      }
      FAnalytics.analytics.setCurrentScreen(
        screenName: pageName,
      );
    });
  }

  _updateWidgets() {
    setState(() {
      _widgetOptions = <Widget>[
        MyRegistryPage(_registry),
        HelperPage(_registry, _sortValue),
        ChartsPage(_registry),
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
