import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:quick_actions/quick_actions.dart';

import 'resources/values/app_colors.dart';
import 'store/authentication.dart';
import 'store/registry_store.dart';
import 'store/user_data_store.dart';
import 'resources/i18n/app_strings.dart';
import 'utils/fanalytics.dart';
import 'widgets/loading.dart';

//https://www.wizardunite.com/2019/05/hpwu-foundables-and-traces.html
//https://github.com/hpwizardsunite-dev-contrib
//https://wizardsunitehub.info/foundables/

class ExplorationWidget extends StatefulWidget {
  ExplorationWidget();

  @override
  State<StatefulWidget> createState() => ExplorationWidgetState();
}

class ExplorationWidgetState extends State<ExplorationWidget> {
  ExplorationWidgetState();

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
              _sortValue = "sort_low".i18n();
              break;
            case 'helper_challenges':
              _selectedIndex = 1;
              _sortValue = "sort_fortress".i18n();
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
        ShortcutItem(
          type: 'helper_low',
          localizedTitle: "shortcut_title_low".i18n(),
          icon: 'ic_wild',
        ),
        ShortcutItem(
          type: 'helper_challenges',
          localizedTitle: "shortcut_title_challenges".i18n(),
          icon: 'ic_challenges',
        ),
        ShortcutItem(
          type: 'charts',
          localizedTitle: "charts".i18n(),
          icon: 'ic_charts',
        ),
        ShortcutItem(
          type: 'my_registry',
          localizedTitle: "my_registry".i18n(),
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
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              title: Text("my_registry".i18n()),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              title: Text("helper".i18n()),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              title: Text("charts".i18n()),
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
      }

      analytics.sendTab(pageName);

    });
  }
}
