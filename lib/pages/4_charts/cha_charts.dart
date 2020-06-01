import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';
import '../../resources/i18n/app_strings.dart';
import 'charts_widgets.dart';

class ChaChartsPage extends StatefulWidget {
  ChaChartsPage();

  @override
  State<StatefulWidget> createState() => ChaChartsPageState();
}

class ChaChartsPageState extends State<ChaChartsPage> {
  ChaChartsPageState();

  FoundablesData _selectedFoundableData;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  void callback(FoundablesData foundable) {
    analytics.sendClickChartEvent();
    setState(() {
      _selectedFoundableData = foundable;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List();

    if (userDataStore.isLoading) {
      widgets.add(LoadingWidget());
    } else {
      widgets.add(_getChartList(userDataStore.data));
      if (_selectedFoundableData != null) {
        widgets.add(GestureDetector(
          onTap: _deleteFoundable,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                height: AppDimens.megaSize,
              ),
              Card(
                color: AppColors.chartsCardColor,
                child: Padding(
                  padding: AppStyles.miniInsets,
                  child: Container(
                    width: AppDimens.chartsCardWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: AppDimens.mediumImageSize,
                          height: AppDimens.mediumImageSize,
                          child: Image.asset("assets/images/foundables/${_selectedFoundableData.id}.png"),
                        ),
                        Text(
                          "${_selectedFoundableData.id.i18n()}",
                          style: AppStyles.darkText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: widgets,
    );
  }

  Widget _getChartList(Map<String, dynamic> data) {
    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        children: <Widget>[
          getChartForChapter(data, "bo", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, null, null, callback),
          getChartForChapter(data, "jp", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, null, null, callback),
          getChartForChapter(data, "md", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, null, null, callback),
          getChartForChapter(data, "sww", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, null, null, callback),
          getChartForChapter(data, "wda", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, null, null, callback),
        ],
      );
    });
  }

  _deleteFoundable() {
    analytics.sendDismissFoundableOverlayEvent();
    setState(() {
      _selectedFoundableData = null;
    });
  }
}