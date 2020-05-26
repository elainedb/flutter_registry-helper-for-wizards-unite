import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../store/authentication.dart';
import '../store/registry_store.dart';
import '../store/ui_store.dart';
import '../store/user_data_store.dart';
import '../resources/i18n/app_strings.dart';
import '../utils/fanalytics.dart';
import '../utils/utils.dart';
import '../widgets/chart.dart';
import '../widgets/loading.dart';
import 'tutorial/charts_helper.dart';

class ChartsPage extends StatefulWidget {
  ChartsPage();

  @override
  State<StatefulWidget> createState() => ChartsPageState();
}

class ChartsPageState extends State<ChartsPage> {
  ChartsPageState();

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
          getChartForChapter(data, "cmc", AppColors.cmcDarkStringHex, AppColors.cmcLightStringHex),
          getChartForChapter(data, "da", AppColors.daDarkStringHex, AppColors.daLightStringHex),
          getChartForChapter(data, "hs", AppColors.hsDarkStringHex, AppColors.hsLightStringHex),
          getChartForChapter(data, "loh", AppColors.lohDarkStringHex, AppColors.lohLightStringHex),
          getChartForChapter(data, "mom", AppColors.momDarkStringHex, AppColors.momLightStringHex),
          getChartForChapter(data, "m", AppColors.mDarkStringHex, AppColors.mLightStringHex),
          getChartForChapter(data, "mgs", AppColors.mgsDarkStringHex, AppColors.mgsLightStringHex),
          getChartForChapter(data, "mar", AppColors.maDarkStringHex, AppColors.maLightStringHex),
          getChartForChapter(data, "www", AppColors.wwwDarkStringHex, AppColors.wwwLightStringHex),
          getChartForChapter(data, "o", AppColors.oDarkStringHex, AppColors.oLightStringHex),
        ],
      );
    });
  }

  Widget getChartForChapter(Map<String, dynamic> data, String chapterId, String dark, String light) {
    var chapter = getChapterWithId(registryStore.registry, chapterId);
    var totalList = List<FoundablesData>();
    var returnedList = List<FoundablesData>();
    var key;
    if (chapterId == "cmc") key = globalKey1;

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        var level = data[foundable.id]["level"];
        var total = getRequirementWithLevel(foundable, level);
        var returned = data[foundable.id]["count"];
        var remainder = total - returned;

        totalList.add(FoundablesData(foundable.id, foundable.id.i18n(), remainder));
        returnedList.add(FoundablesData(foundable.id, foundable.id.i18n(), returned));
      });
    });

    List<charts.Series<FoundablesData, String>> chartData = [
      charts.Series<FoundablesData, String>(
        id: 'Total',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: totalList,
        colorFn: (_, __) => charts.Color.fromHex(code: light),
      ),
      charts.Series<FoundablesData, String>(
        id: 'Returned',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: returnedList,
        colorFn: (_, __) => charts.Color.fromHex(code: dark),
      )
    ];

    return Column(
      children: <Widget>[
        Text(
          chapter.id.i18n(),
          style: AppStyles.chartsTitle(Color(hexToInt(light))),
        ),
        Stack(
          key: key,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            getPageSeparators(chapter),
            StackedBarChart(chartData, true, callback),
            Container(
              margin: AppStyles.chartsInsets,
              child: getHowToCatchForChapter(chapter),
            ),
          ],
        ),
        Container(
          height: AppDimens.megaSize,
        ),
      ],
    );
  }

  Widget getHowToCatchForChapter(Chapter chapter) {
    List<Widget> list = List();
    List<Widget> listPlaced = List();
    var key;
    if (chapter.id == "cmc") key = globalKey2;

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        bool isPlaced = userDataStore.data[foundable.id]['placed'];
        list.add(getIconWithFoundable(foundable, AppDimens.smallSize));
        listPlaced.add(
          Icon(
            Icons.stars,
            color: isPlaced ? Colors.green : Colors.grey,
            size: AppDimens.miniImageSize,
          ),
        );
      });
    });

    return Padding(
      padding: AppStyles.chartsHowToCatchInsets,
      child: Column(
        children: [
          Row(
            key: key,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: list,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: listPlaced,
          ),
        ],
      ),
    );
  }

  Widget getPageSeparators(Chapter chapter) {
    List<Widget> list = List();

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        var color = AppColors.backgroundColor;
        if (foundable.id.contains("_1")) {
          color = AppColors.chartsSeparatorColor;
        }

        Widget w = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Flex(
              children: List.generate(AppDimens.dashCount, (_) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      width: AppDimens.dashWidth,
                      height: AppDimens.dashHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: color),
                      ),
                    ),
                    Container(
                      height: AppDimens.nanoSize,
                    )
                  ],
                );
              }),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
            );
          },
        );

        list.add(w);
      });
    });

    list.removeAt(0);

    return Column(
      children: <Widget>[
        Padding(
          padding: AppStyles.chartsSeparatorsInsets,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: list,
          ),
        ),
        Container(
          height: AppDimens.largeSize,
        ),
      ],
    );
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

class FoundablesData {
  final String id;
  final String name;
  final int count;

  FoundablesData(this.id, this.name, this.count);
}
