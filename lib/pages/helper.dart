import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../widgets/loading.dart';
import 'tutorial/helper_tutorial.dart';

class HelperPage extends StatefulWidget {
  final Registry _registry;
  final String _initialSortValue;
  final FirebaseAnalyticsObserver _observer;
  final FirebaseAnalytics _analytics;
  HelperPage(this._registry, this._initialSortValue, this._observer, this._analytics);

  @override
  State<StatefulWidget> createState() => HelperPageState(_registry, _initialSortValue, _observer, _analytics);
}

class HelperPageState extends State<HelperPage> with SingleTickerProviderStateMixin {
  final Registry _registry;
  String _initialSortValue;
  final FirebaseAnalyticsObserver _observer;
  final FirebaseAnalytics _analytics;
  HelperPageState(this._registry, this._initialSortValue, this._observer, this._analytics);

  String _dropdownValue = sortValues[0];
  String _userId;
  int _initialIndex = 0;
  bool _isUserAnonymous;
  UserData _userData;
  TabController _controller;

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  bool _tutorialShown;

  @override
  void initState() {
    super.initState();
    HelperTutorial.initTargets(globalKey1, globalKey2, globalKey3);
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

    if (_isUserAnonymous != null && _isUserAnonymous && _userData != null) {
      return _tabController(_userData.fragmentDataList);
    } else {
      if (_userId != null) {
        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                return _tabController(snapshot.data.data);
              } else
                return LoadingWidget();
            });
      }
    }
    return LoadingWidget();
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
                Tab(text: "Missing Foundables"),
                Tab(key: globalKey3, text: "Insights"),
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
        "Below is the missing count for all foundables in a family. You can use it to help you decide which trace to click if you have a cluster!",
        style: AppStyles.lightContentText,
      ),
    ));
    widgets.add(Padding(
      padding: AppStyles.miniInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Sort by:',
            style: AppStyles.lightContentText,
          ),
          Theme(
            data: AppStyles.helperDropdownThemeData,
            child: DropdownButton<String>(
              key: globalKey2,
              value: _dropdownValue,
              onChanged: (newValue) {
                setState(() {
                  _dropdownValue = newValue;
                  _sendAnalyticsEvents();
                });
              },
              items: sortValues.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
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
      var chapter = getChapterWithId(_registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, data);
      var value = index;
      switch (_dropdownValue) {
        case 'Low/Medium (no beam)':
          value = missingTraces.low + missingTraces.medium;
          break;
        case 'High (yellow beam)':
          value = missingTraces.high;
          break;
        case 'Severe (orange beam)':
          value = missingTraces.severe;
          break;
        case 'Emergency (red beam)':
          value = missingTraces.emergency;
          break;
        case 'Wizarding Challenges rewards':
          value = missingTraces.challenges;
          break;
      }
      chapterRowsMap[_chapterRow(chapterForDisplay, chapter, missingTraces)] = value;
    });

    if (_dropdownValue != 'Default') {
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

    return ListView(
      children: widgets,
    );
  }

  _sendAnalyticsEvents() async {
    await _analytics.logEvent(
      name: 'missing_foundables_dropdown_value',
      parameters: <String, dynamic>{'value': _dropdownValue},
    );
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

    return ListView(
      shrinkWrap: true,
      children: widgets,
    );
  }

  List<Widget> _getPagesWithOneOreTwoMissingWidgets(Map<String, dynamic> data) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.mediumInsets,
      child: Text(
        "Focused playing: this is a list of pages that have only one or two remaining foundables in order to be complete!",
        style: AppStyles.lightContentText,
        textAlign: TextAlign.center,
      ),
    ));
    chaptersForDisplay.forEach((chapterForDisplay) {
      var chapter = getChapterWithId(_registry, chapterForDisplay.id);
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
          Container(
            width: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/traces_transparent/$chapterId.png"),
          ),
          Container(
            width: AppDimens.mediumImageSize,
            height: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/foundables/${foundable.foundable.id}.png"),
          ),
          Container(
            width: AppDimens.mediumImageSize,
            child: getIconWithFoundable(foundable.foundable, AppDimens.smallImageSize),
          ),
          Text(
            "${foundable.remainingFragments} left",
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
      var chapter = getChapterWithId(_registry, chapterForDisplay.id);
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
          "Below is your no-click zone! You currently have no missing foundables on your Registry for the following families/categories:",
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

      _observer.analytics.setCurrentScreen(
        screenName: pageName,
      );
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
                            chapter.name,
                            style: AppStyles.helperDialogTitleText(chapterForDisplay.darkColor),
                      )),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "Open Street Maps Value/Category:",
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          chapter.osm,
                          style: AppStyles.helperDialogBoldBodyText(chapterForDisplay.darkColor),
                        ),
                      ),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "Examples:",
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          chapter.examples,
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
