import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../utils/utils.dart';
import '../widgets/loading.dart';
import '../widgets/chart.dart';


class ChartsPage extends StatefulWidget {
  final Registry _registry;
  final FirebaseAnalytics _analytics;
  ChartsPage(this._registry, this._analytics);

  @override
  State<StatefulWidget> createState() => ChartsPageState(_registry, _analytics);
}

class ChartsPageState extends State<ChartsPage> {
  final Registry _registry;
  final FirebaseAnalytics _analytics;
  ChartsPageState(this._registry, this._analytics);

  String _userId;
  FoundablesData _selectedFoundableData;
  bool _isUserAnonymous;
  UserData _userData;

  List<TargetFocus> targets = List();
  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  bool _tutorialShown;

  @override
  void initState() {
    super.initState();
    initTargets();
    _getTutorialInfoFromSharedPrefs();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _isUserAnonymous = user.isAnonymous;
          if (user.isAnonymous) {
            getUserDataFromPrefs().then((data) => _userData = data);
          }
        });
      }
    });
  }

  void callback(FoundablesData foundable) {
    setState(() {
      _sendClickChartEvent();
      _selectedFoundableData = foundable;
    });
  }

  initTargets() {
    targets.add(
      TargetFocus(
        identify: "target1",
        keyTarget: globalKey1,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
              align: AlignContent.top,
              child: Text(
                "You can visualize your progress here. Click on a bar in order to see the foundable behind it.",
                style: AppStyles.tutorialText,
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target2",
        keyTarget: globalKey2,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Text(
              "Information about the threat level (color) and how to catch (icon) is shown here.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target3",
        keyTarget: globalKey3,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Text(
              "Here's the legend for the icons shown below the charts.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List();
    if (_isUserAnonymous != null && _isUserAnonymous && _userData != null) {
      widgets.add(_getChartList(_userData.fragmentDataList));
    } else {
      if (_userId != null) {
        widgets.add(StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                return _getChartList(snapshot.data.data);
              } else
                return LoadingWidget();
            }));
      }
    }

    if (_selectedFoundableData != null) {
      widgets.add(
          GestureDetector(
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
                            "${_selectedFoundableData.name}",
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
          )
      );
    }

    if (widgets.isEmpty) {
      widgets.add(LoadingWidget());
    }

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: widgets,
    );

  }

  Widget _getChartList(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));
    return ListView(
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
                    "Threat Level",
                    style: AppStyles.lightBoldContentText,
                  ),
                  Container(
                    height: AppDimens.miniSize,
                  ),
                  getThreatLevelRow(AppColors.lowThreatColor, "Low"),
                  getThreatLevelRow(AppColors.mediumThreatColor, "Medium"),
                  getThreatLevelRow(AppColors.highThreatColor, "High"),
                  getThreatLevelRow(AppColors.severeThreatColor, "Severe"),
                  getThreatLevelRow(AppColors.emergencyThreatColor, "Emergency"),
                ],
              ),
              Container(
                width: AppDimens.megaSize,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "How to catch",
                    style: AppStyles.lightBoldContentText,
                  ),
                  Container(
                    height: AppDimens.miniSize,
                  ),
                  getHowToRow(Icons.pets, "Wild"),
                  getHowToRow(Icons.vpn_key, "Portkey / Wild"),
                  getHowToRow(Icons.flash_on, "Wizarding Challenges"),
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
        getChartForChapter(data, "ma", AppColors.maDarkStringHex, AppColors.maLightStringHex),
        getChartForChapter(data, "www", AppColors.wwwDarkStringHex, AppColors.wwwLightStringHex),
        getChartForChapter(data, "o", AppColors.oDarkStringHex, AppColors.oLightStringHex),
      ],
    );
  }

  Widget getChartForChapter(Map<String, dynamic> data, String chapterId, String dark, String light) {
    var chapter = getChapterWithId(_registry, chapterId);
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

        totalList.add(FoundablesData(foundable.id, foundable.name, remainder));
        returnedList.add(FoundablesData(foundable.id, foundable.name, returned));
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
          chapter.name,
          style: AppStyles.chartsTitle(Color(hexToInt(light))),
        ),
        Stack(
          key: key,
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            getPageSeparators(chapter),
            StackedBarChart(chartData, true, callback),
            getHowToCatchForChapter(chapter),
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
    var key;
    if (chapter.id == "cmc") key = globalKey2;

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        list.add(getIconWithFoundable(foundable, AppDimens.smallSize));
      });
    });

    return Padding(
      padding: AppStyles.chartsHowToCatchInsets,
      child: Row(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: list,
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

  Widget getHowToRow(IconData iconData, String text) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          color: Colors.white,
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
    _sendDismissFoundableOverlayEvent();
    setState(() {
      _selectedFoundableData = null;
    });
  }

  _sendClickChartEvent() async {
    await _analytics.logEvent(
      name: 'click_chart',
    );
  }

  _sendDismissFoundableOverlayEvent() async {
    await _analytics.logEvent(
      name: 'click_dismiss_foundable',
    );
  }

  void showTutorial() {
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.brown,
      textSkip: "SKIP",
      paddingFocus: 0,
      opacityShadow: 0.8,
      finish: () {
        print("finish");
      },
      clickTarget: (target) {
        print(target);
      },
      clickSkip: () {
        print("skip");
      },
    )..show();
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        showTutorial();
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
