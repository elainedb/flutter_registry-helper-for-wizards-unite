import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:quick_actions/quick_actions.dart';

import 'resources/values/app_colors.dart';
import 'store/authentication.dart';
import 'store/registry_store.dart';
import 'store/user_data_store.dart';
import 'utils/fanalytics.dart';
import 'widgets/loading.dart';

//https://www.wizardunite.com/2019/05/hpwu-foundables-and-traces.html
//https://github.com/hpwizardsunite-dev-contrib
//https://wizardsunitehub.info/foundables/

class BottomBarNavWidget extends StatefulWidget {
  BottomBarNavWidget();

  @override
  State<StatefulWidget> createState() => BottomBarNavWidgetState();
}

class BottomBarNavWidgetState extends State<BottomBarNavWidget> {
  BottomBarNavWidgetState();

  String _shortcut = "";
  String _sortValue = "";

  int _selectedIndex = 0;

  final registryStore = GetIt.instance<RegistryStore>();
  final authentication = GetIt.instance<Authentication>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();

  @override
  void initState() {
    super.initState();

    analytics.sendUserId(authentication.userId);

    registryStore.initRegistryDataFromJson().then((_) {
      if (registryStore.registry == null) {
        registryStore.getRegistryFromSharedPrefs();
      }
      registryStore.updateWidgets(_sortValue);

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
          registryStore.updateWidgets(_sortValue);
        });
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

      userDataStore.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build for _userId = ${authentication.userId}, selectedIndex = $_selectedIndex, sortValue = $_sortValue, shortcut = $_shortcut');

    return Observer(builder: (BuildContext context) {
      if (authentication.userId.isEmpty || registryStore.isLoading) {
        return LoadingWidget();
      }
      return Scaffold(
        body: registryStore.widgetOptions.elementAt(_selectedIndex),
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
      switch (index) {
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

      analytics.sendTab(pageName);

    });
  }
}
