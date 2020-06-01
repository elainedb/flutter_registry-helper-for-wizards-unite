import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'resources/values/app_colors.dart';
import 'store/authentication.dart';
import 'store/registry_store.dart';
import 'store/user_data_store.dart';
import 'resources/i18n/app_strings.dart';
import 'utils/fanalytics.dart';
import 'widgets/loading.dart';

class ChallengesWidget extends StatefulWidget {
  ChallengesWidget();

  @override
  State<StatefulWidget> createState() => ChallengesWidgetState();
}

class ChallengesWidgetState extends State<ChallengesWidget> {
  ChallengesWidgetState();

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
      registryStore.updateChallengesWidgets();

      userDataStore.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build CHA for _userId = ${authentication.userId}');

    return Observer(builder: (BuildContext context) {
      if (authentication.userId.isEmpty || registryStore.isLoading) {
        return LoadingWidget();
      }
      return Scaffold(
        body: registryStore.challengesWidgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              title: Text("my_registry".i18n()),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              title: Text("assistant".i18n()),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              title: Text("insights".i18n()),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              title: Text("charts".i18n()),
            ),
          ],
          selectedItemColor: AppColors.backgroundColor,
          unselectedItemColor: AppColors.backgroundColorUnselected,
          backgroundColor: AppColors.challengesBackgroundColor,
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
          pageName = "ChaMyRegistryPage";
          break;
        case 1:
          pageName = "ChaAssistantPage";
          break;
        case 2:
          pageName = "ChaInsightsPage";
          break;
        case 3:
          pageName = "ChaChartsPage";
          break;
      }

      analytics.sendTab(pageName);

    });
  }
}
