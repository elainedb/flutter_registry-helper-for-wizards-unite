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
import '../widgets/loading.dart';
import 'tutorial/helper_tutorial.dart';

class HelperPage extends StatefulWidget {
  final String _initialSortValue;
  HelperPage(this._initialSortValue);

  @override
  State<StatefulWidget> createState() => HelperPageState(_initialSortValue);
}

class HelperPageState extends State<HelperPage> with SingleTickerProviderStateMixin {
  String _initialSortValue;
  HelperPageState(this._initialSortValue);

  String _dropdownValue = sortValues[0];
  int _initialIndex = 0;
  TabController _controller;

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
    HelperTutorial.initTargets(globalKey1, globalKey2, globalKey3);
    _getTutorialInfoFromSharedPrefs();

    if (_initialSortValue.isNotEmpty) {
      _dropdownValue = _initialSortValue;
    }

    _controller = TabController(vsync: this, length: 2);
    _controller.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    if (widget._initialSortValue.isNotEmpty) {
      // fix for shortcut when page already displaying
      _dropdownValue = widget._initialSortValue;
      _initialSortValue = "";
    }

    if (userDataStore.isLoading) {
      return LoadingWidget();
    } else {
      return _tabController(userDataStore.data);
    }
  }

  Widget _tabController(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));
    return DefaultTabController(
      initialIndex: _initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: SafeArea(
            child: TabBar(
              controller: _controller,
              labelColor: Colors.amber,
              indicatorColor: Colors.amber,
              tabs: [
                Tab(text: "missing_foundables_title".i18n()),
                Tab(key: globalKey3, text: "insights".i18n()),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            _generalHelper(data),
            _insights(data),
          ],
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }

  Widget _generalHelper(Map<String, dynamic> data) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.miniInsets,
      child: Text(
        "missing_foundables_description".i18n(),
        style: AppStyles.lightContentText,
      ),
    ));
    widgets.add(Padding(
      padding: AppStyles.miniInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "sort_by".i18n(),
            style: AppStyles.lightContentText,
          ),
          Theme(
            data: AppStyles.helperDropdownThemeData,
            child: DropdownButton<String>(
              key: globalKey2,
              value: _dropdownValue,
              onChanged: (newValue) {
                analytics.sendAnalyticsEvents(_dropdownValue);
                setState(() {
                  _dropdownValue = newValue;
                });
              },
              items: sortValues.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.i18n(),
                    style: AppStyles.lightContentText,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ));

    Map<Widget, int> chapterRowsMap = Map();
    chaptersForDisplay.asMap().forEach((index, chapterForDisplay) {
      var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, data);
      var value = index;

      if (_dropdownValue == "sort_low")
        value = missingTraces.low + missingTraces.medium;
      else if (_dropdownValue == "sort_high")
        value = missingTraces.high;
      else if (_dropdownValue == "sort_severe")
        value = missingTraces.severe;
      else if (_dropdownValue == "sort_emergency")
        value = missingTraces.emergency;
      else if (_dropdownValue == "sort_fortress") value = missingTraces.challenges;
      chapterRowsMap[_chapterRow(chapterForDisplay, chapter, missingTraces)] = value;
    });

    if (_dropdownValue != "sort_default") {
      var sortedValues = chapterRowsMap.values.toList()..sort();
      sortedValues.reversed.forEach((i) {
        var key = chapterRowsMap.keys.firstWhere((k) => chapterRowsMap[k] == i && !widgets.contains(k));
        widgets.add(key);
      });
    } else {
      chapterRowsMap.forEach((chapterRow, count) {
        widgets.add(chapterRow);
      });
    }

    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        children: widgets,
      );
    });
  }

  Widget _insights(Map<String, dynamic> data) {
    List<Widget> widgets = List();

    if (_getNoClickWidgets(data) != null) {
      widgets.addAll(_getNoClickWidgets(data));
    }

    if (_getPagesWithOneOreTwoMissingWidgets(data) != null) {
      widgets.addAll(_getPagesWithOneOreTwoMissingWidgets(data));
    }

    if (_getPagesWithOneOreTwoMissingWidgets(data) == null && _getNoClickWidgets(data) == null) {
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

  List<Widget> _getPagesWithOneOreTwoMissingWidgets(Map<String, dynamic> data) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.mediumInsets,
      child: Text(
        "focused_playing".i18n(),
        style: AppStyles.lightContentText,
        textAlign: TextAlign.center,
      ),
    ));
    chaptersForDisplay.forEach((chapterForDisplay) {
      var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
      List<AlmostCompletePage> almostCompletePages = getPagesWithOneOreTwoMissing(chapter, data);
      almostCompletePages.forEach((almostCompletePage) {
        widgets.add(_getAlmostCompletePageWidget(almostCompletePage, chapter.id));
      });
    });

    if (widgets.length == 1) {
      return null;
    }
    return widgets;
  }

  Widget _getAlmostCompletePageWidget(AlmostCompletePage almostCompletePage, String chapterId) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.helperAlmostCompleteInsets,
      child: Text(
        almostCompletePage.pageName,
        style: AppStyles.lightContentText,
      ),
    ));
    almostCompletePage.foundables.forEach((foundable) {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/traces_transparent/$chapterId.png"),
          ),
          SizedBox(
            width: AppDimens.mediumImageSize,
            height: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/foundables/${foundable.foundable.id}.png"),
          ),
          SizedBox(
            width: AppDimens.smallImageSize,
            child: getIconWithFoundable(foundable.foundable, AppDimens.smallImageSize),
          ),
          Text(
            "left".i18n().replaceFirst("arg1", "${foundable.remainingFragments}"),
            style: AppStyles.lightContentText,
          ),
        ],
      ));
    });
    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: AppStyles.miniInsets,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> _getNoClickWidgets(Map<String, dynamic> data) {
    List<ZeroTracesLeft> zeroTracesLeftList = List();
    chaptersForDisplay.forEach((chapterForDisplay) {
      var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, data);
      if (missingTraces.low + missingTraces.medium == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "low/medium"));
      }
      if (missingTraces.high == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "high"));
      }
      if (missingTraces.severe == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "severe"));
      }
      if (missingTraces.emergency == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "emergency"));
      }
      if (missingTraces.challenges == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "challenges"));
      }
    });

    List<Widget> gridViewWidgets = List();
    zeroTracesLeftList.forEach((zero) {
      gridViewWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _getZeroWidget(zero),
        ],
      ));
    });

    List<Widget> widgets = List();
    if (gridViewWidgets.length > 0) {
      widgets.add(Padding(
        padding: AppStyles.miniInsets,
        child: Text(
          "no_click_zone".i18n(),
          style: AppStyles.lightContentText,
          textAlign: TextAlign.center,
        ),
      ));
      widgets.add(IgnorePointer(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          children: gridViewWidgets,
        ),
      ));
    }

    return widgets;
  }

  Widget _getZeroWidget(ZeroTracesLeft zeroTracesLeft) {
    Color color = Colors.transparent;
    switch (zeroTracesLeft.type) {
      case "high":
        color = AppColors.highThreatColor;
        break;
      case "severe":
        color = AppColors.severeThreatColor;
        break;
      case "emergency":
        color = AppColors.emergencyThreatColor;
        break;
    }

    if (zeroTracesLeft.type == "challenges") {
      return Container(
        width: AppDimens.largeImageSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: AppDimens.mediumImageSize,
              child: Image.asset("assets/images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
            ),
            Padding(
              padding: AppStyles.helperChallengesInsets,
              child: Icon(
                Icons.flash_on,
                color: Colors.white,
                size: AppDimens.smallImageSize,
              ),
            )
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.brightness_1,
            color: color,
            size: AppDimens.largeImageSize,
          ),
          Container(
            width: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
          ),
        ],
      );
    }
  }

  Widget _chapterRow(ChapterForDisplay chapterForDisplay, Chapter chapter, MissingTraces missingTraces) {
    var key;
    if (chapterForDisplay.id == "cmc") {
      key = globalKey1;
    }
    return GestureDetector(
      onTap: () => _pushDialog(chapterForDisplay, chapter),
      child: Card(
        key: key,
        color: chapterForDisplay.lightColor,
        child: Padding(
          padding: AppStyles.helperChapterInsets,
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.largeImageSize,
                child: Hero(
                  tag: chapterForDisplay.id,
                  child: Image.asset("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _missingWidget(AppColors.lowAltThreatColor, "${missingTraces.low + missingTraces.medium}", Icons.radio_button_unchecked),
                    _missingWidget(AppColors.highThreatColor, "${missingTraces.high}", Icons.brightness_1),
                    _missingWidget(AppColors.severeThreatColor, "${missingTraces.severe}", Icons.brightness_1),
                    _missingWidget(AppColors.emergencyThreatColor, "${missingTraces.emergency}", Icons.brightness_1),
                    _missingChallenges("${missingTraces.challenges}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missingWidget(Color color, String text, IconData iconData) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(
          iconData,
          color: color,
          size: AppDimens.missingWidgetSize,
        ),
        Text(
          text,
          style: AppStyles.darkContentText,
        ),
      ],
    );
  }

  Widget _missingChallenges(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.flash_on,
          size: AppDimens.mediumSize,
        ),
        Container(
            width: AppDimens.largeSize,
            child: Text(
              text,
              style: AppStyles.darkContentText,
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  _handleTabSelection() {
    setState(() {
      String pageName = "";
      switch (_controller.index) {
        case 0:
          pageName = "HelperPage_MissingFoundables";
          break;
        case 1:
          pageName = "HelperPage_Insights";
          break;
      }

      analytics.sendTab(pageName);
    });
  }

  _pushDialog(ChapterForDisplay chapterForDisplay, Chapter chapter) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (BuildContext context, _, __) {
        return Center(
          child: Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 5,
                margin: AppStyles.helperDialogCardInsets,
                color: chapterForDisplay.lightColor,
                child: Padding(
                  padding: AppStyles.helperDialogPaddingInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Center(
                          child: Text(
                        chapter.id.i18n(),
                        style: AppStyles.helperDialogTitleText(chapterForDisplay.darkColor),
                      )),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "osm_value".i18n(),
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          "${chapter.id}_osm".i18n(),
                          style: AppStyles.helperDialogBoldBodyText(chapterForDisplay.darkColor),
                        ),
                      ),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "examples".i18n(),
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          "${chapter.id}_examples".i18n(),
                          style: AppStyles.helperDialogBoldBodyText(chapterForDisplay.darkColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppDimens.negativeDialogMargin,
                child: Hero(
                  tag: chapterForDisplay.id,
                  child: Image(
                    image: AssetImage("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                    width: AppDimens.megaImageSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        HelperTutorial.showTutorial(context);
        setState(() {
          setTutorialShown();
        });
      }
    });
  }

  Future<void> setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorialShown = true;
    await prefs.setBool('tutorialHelper', true);
  }

  _getTutorialInfoFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tutorialRegistryShown = prefs.getBool('tutorialHelper') ?? false;
    setState(() {
      _tutorialShown = tutorialRegistryShown;
    });
  }
}

class MissingTraces {
  final int low;
  final int medium;
  final int high;
  final int severe;
  final int emergency;
  final int challenges;

  MissingTraces(this.low, this.medium, this.high, this.severe, this.emergency, this.challenges);
}

class ZeroTracesLeft {
  final String chapterId;
  final String type;

  ZeroTracesLeft(this.chapterId, this.type);
}
