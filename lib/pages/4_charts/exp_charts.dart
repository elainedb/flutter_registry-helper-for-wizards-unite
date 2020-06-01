import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../resources/i18n/app_strings.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';
import 'charts_widgets.dart';
import 'tutorial.dart';

class ExpChartsPage extends StatefulWidget {
  ExpChartsPage();

  @override
  State<StatefulWidget> createState() => ExpChartsPageState();
}

class ExpChartsPageState extends State<ExpChartsPage> {
  ExpChartsPageState();

  FoundablesData _selectedFoundableData;

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  bool _tutorialShown;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  void initState() {
    super.initState();
    ChartsTutorial.initTargets(globalKey1, globalKey2, globalKey3);
    _getTutorialInfoFromSharedPrefs();
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));
    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: AppStyles.mediumInsets,
            child: Row(
              key: globalKey3,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "threat_level".i18n(),
                      style: AppStyles.lightBoldContentText,
                    ),
                    Container(
                      height: AppDimens.miniSize,
                    ),
                    getThreatLevelRow(AppColors.lowThreatColor, "threat_level_low".i18n()),
                    getThreatLevelRow(AppColors.mediumThreatColor, "threat_level_medium".i18n()),
                    getThreatLevelRow(AppColors.highThreatColor, "threat_level_high".i18n()),
                    getThreatLevelRow(AppColors.severeThreatColor, "threat_level_severe".i18n()),
                    getThreatLevelRow(AppColors.emergencyThreatColor, "threat_level_emergency".i18n()),
                  ],
                ),
                Container(
                  width: AppDimens.megaSize,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "how_to_catch".i18n(),
                      style: AppStyles.lightBoldContentText,
                    ),
                    Container(
                      height: AppDimens.miniSize,
                    ),
                    getHowToRow("🌳", "how_to_catch_wild".i18n()),
                    getHowToRow("🔑️", "how_to_catch_portkey".i18n()),
                    getHowToRow("⚔️", "how_to_catch_fortress".i18n()),
                  ],
                ),
              ],
            ),
          ),
          getChartForChapter(data, "cmc", AppColors.cmcDarkStringHex, AppColors.cmcLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "da", AppColors.daDarkStringHex, AppColors.daLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "hs", AppColors.hsDarkStringHex, AppColors.hsLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "loh", AppColors.lohDarkStringHex, AppColors.lohLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "mom", AppColors.momDarkStringHex, AppColors.momLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "m", AppColors.mDarkStringHex, AppColors.mLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "mgs", AppColors.mgsDarkStringHex, AppColors.mgsLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "mar", AppColors.maDarkStringHex, AppColors.maLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "www", AppColors.wwwDarkStringHex, AppColors.wwwLightStringHex, globalKey1, globalKey2, callback),
          getChartForChapter(data, "o", AppColors.oDarkStringHex, AppColors.oLightStringHex, globalKey1, globalKey2, callback),
        ],
      );
    });
  }

  Widget getThreatLevelRow(Color color, String text) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.brightness_1,
          color: color,
        ),
        Container(
          width: AppDimens.microSize,
        ),
        Text(
          text,
          style: AppStyles.lightContentText,
        ),
      ],
    );
  }

  Widget getHowToRow(String data, String text) {
    return Row(
      children: <Widget>[
        Text(
          data,
        ),
        Container(
          width: AppDimens.microSize,
        ),
        Text(
          text,
          style: AppStyles.lightContentText,
        ),
      ],
    );
  }

  _deleteFoundable() {
    analytics.sendDismissFoundableOverlayEvent();
    setState(() {
      _selectedFoundableData = null;
    });
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        ChartsTutorial.showTutorial(context);
        setState(() {
          setTutorialShown();
        });
      }
    });
  }

  Future<void> setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorialShown = true;
    await prefs.setBool('tutorialCharts', true);
  }

  _getTutorialInfoFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tutorialRegistryShown = prefs.getBool('tutorialCharts') ?? false;
    setState(() {
      _tutorialShown = tutorialRegistryShown;
    });
  }
}
