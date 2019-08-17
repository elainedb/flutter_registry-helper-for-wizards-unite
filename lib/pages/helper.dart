import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../main.dart';

class HelperPage extends StatefulWidget {
  final Registry _registry;
  String _initialSortValue;
  final FirebaseAnalyticsObserver _observer;
  final FirebaseAnalytics _analytics;
  HelperPage(this._registry, this._initialSortValue, this._observer, this._analytics);

  @override
  State<StatefulWidget> createState() => HelperPageState(_registry, _initialSortValue, _observer, _analytics);
}

class HelperPageState extends State<HelperPage> with SingleTickerProviderStateMixin {
  final Registry _registry;
  final String _initialSortValue;
  final FirebaseAnalyticsObserver _observer;
  final FirebaseAnalytics _analytics;
  HelperPageState(this._registry, this._initialSortValue, this._observer, this._analytics);

  String _dropdownValue = sortValues[0];
  String _userId;
  int _initialIndex = 0;
  bool _isUserAnonymous;
  UserData _userData;
  TabController _controller;

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
      widget._initialSortValue = "";
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
                return Center(
                  child: Text("Loading"),
                );
            });
      }
    }
    return Center(child: Text("Loading"));
  }

  initTargets() {
    targets.add(
      TargetFocus(
        identify: "target1",
        keyTarget: globalKey1,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
              align: AlignContent.bottom,
              child: Text(
                "Here you can find how many fragments are missing for each threat level. Information about where you can find nests for the family can be consulted by clicking here.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
              "You can sort this list by Threat Level or Wizarding Challenges.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
              "You can find personalized insights here.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _generalHelper(Map<String, dynamic> data) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        "Below is the missing count for all foundables in a family. You can use it to help you decide which trace to click if you have a cluster!",
        style: TextStyle(color: Colors.white),
      ),
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Sort by:',
            style: TextStyle(color: Colors.white),
          ),
          Theme(
            data: ThemeData(
              canvasColor: backgroundColor,
              fontFamily: 'Raleway',
            ),
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
                    style: TextStyle(color: Colors.white),
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
        style: TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.all(16),
      child: Text(
        "Focused playing: this is a list of pages that have only one or two remaining foundables in order to be complete!",
        style: TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        almostCompletePage.pageName,
        style: TextStyle(color: Colors.white),
      ),
    ));
    almostCompletePage.foundables.forEach((foundable) {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 50,
            child: Image.asset("assets/images/traces_transparent/${chapterId}.png"),
          ),
          Container(
            width: 50,
            height: 50,
            child: Image.asset("assets/images/foundables/${foundable.foundable.id}.png"),
          ),
          Container(
            width: 50,
            child: getIconWithFoundable(foundable.foundable, 30),
          ),
          Text(
            "${foundable.remainingFragments} left",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
    });
    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Below is your no-click zone! You currently have no missing foundables on your Registry for the following families/categories:",
          style: TextStyle(color: Colors.white),
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
        color = Colors.yellow;
        break;
      case "severe":
        color = Colors.orange;
        break;
      case "emergency":
        color = Colors.red;
        break;
    }

    if (zeroTracesLeft.type == "challenges") {
      return Container(
        width: 80,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 50,
              child: Image.asset("assets/images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 0, 0, 0),
              child: Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 30,
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
            size: 80,
          ),
          Container(
            width: 50,
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
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 75,
                child: Hero(
                  tag: "${chapterForDisplay.id}",
                  child: Image.asset("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _missingWidget(Colors.black, "${missingTraces.low + missingTraces.medium}", Icons.radio_button_unchecked),
                    _missingWidget(Colors.yellow, "${missingTraces.high}", Icons.brightness_1),
                    _missingWidget(Colors.orange, "${missingTraces.severe}", Icons.brightness_1),
                    _missingWidget(Colors.red, "${missingTraces.emergency}", Icons.brightness_1),
                    _missingChallegnges("${missingTraces.challenges}"),
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
          size: 40,
        ),
        Text(text),
      ],
    );
  }

  Widget _missingChallegnges(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.flash_on,
          size: 16,
        ),
        Container(
            width: 20,
            child: Text(
              text,
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
                margin: EdgeInsets.symmetric(horizontal: 16),
                color: chapterForDisplay.lightColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 8, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 24,
                      ),
                      Center(
                          child: Text(
                        chapter.name,
                        style: TextStyle(color: chapterForDisplay.darkColor, fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                      Container(
                        height: 24,
                      ),
                      Text(
                        "Open Street Maps Value/Category:",
                        style: TextStyle(color: chapterForDisplay.darkColor, fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          chapter.osm,
                          style: TextStyle(color: chapterForDisplay.darkColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 24,
                      ),
                      Text(
                        "Examples:",
                        style: TextStyle(color: chapterForDisplay.darkColor, fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          chapter.examples,
                          style: TextStyle(color: chapterForDisplay.darkColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -120,
                child: Hero(
                  tag: chapterForDisplay.id,
                  child: Image(
                    image: AssetImage("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                    width: 160,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ));
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
