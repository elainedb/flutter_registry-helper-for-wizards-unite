import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';
import 'insights_widgets.dart';

class ChaInsightsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ChaInsightsPageState();
}

class ChaInsightsPageState extends State<ChaInsightsPage> {

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  Widget build(BuildContext context) {
    if(userDataStore.isLoading) {
      return LoadingWidget();
    } else {
      return _insights(userDataStore.data);
    }
  }

  Widget _insights(Map<String, dynamic> data) {
    List<Widget> widgets = List();

    if (getPagesWithOneOreTwoMissingWidgets(data, challengesChaptersForDisplay) != null) {
      widgets.addAll(getPagesWithOneOreTwoMissingWidgets(data, challengesChaptersForDisplay));
    }

    if (getPagesWithOneOreTwoMissingWidgets(data, challengesChaptersForDisplay) == null) {
      return Text(
        "No insights for now!",
        style: AppStyles.lightContentText,
      );
    }

    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: widgets,
      );
    });
  }
}