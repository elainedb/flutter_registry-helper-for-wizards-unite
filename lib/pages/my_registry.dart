import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/bottom_bar_nav.dart';
import 'package:registry_helper_for_wu/widgets/page_edit_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../main.dart';

class MyRegistryPage extends StatefulWidget {
  final Registry _registry;
  final FirebaseAnalytics _analytics;
  MyRegistryPage(this._registry, this._analytics);

  @override
  State<StatefulWidget> createState() => MyRegistryPageState(_registry, _analytics);
}

class MyRegistryPageState extends State<MyRegistryPage> {
  final Registry _registry;
  final FirebaseAnalytics _analytics;
  MyRegistryPageState(this._registry, this._analytics);

  String _userId;
  AutoScrollController controller;
  bool _isUserAnonymous;
  UserData _userData;

  List<TargetFocus> targets = List();
  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  GlobalKey globalKey4 = GlobalKey();
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

    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserAnonymous != null && _isUserAnonymous && _userData != null) {
      return registryWidget(_userData.fragmentDataList);
    } else {
      if (_userId != null) {
        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
            builder: (context, snapshot) {
              if (_registry != null && snapshot.hasData && snapshot.data.data != null) {
                return registryWidget(snapshot.data.data);
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
                "Click here to edit the fragment count for this page.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.right,
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
              "After successfully retrieving a foundable, click on this button to add a fragment.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.right,
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
              "Set your current prestige level here.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target4",
        keyTarget: globalKey4,
        shape: ShapeLightFocus.Circle,
        contents: [
          ContentTarget(
            align: AlignContent.left,
            child: Text(
              "\nQuickly access other families.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget registryWidget(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));

    return Row(
      children: <Widget>[
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            controller: controller,
            children: <Widget>[
              chapterCard("cmc", data, cmcDark, cmcLight, 0),
              chapterCard("da", data, daDark, daLight, 1),
              chapterCard("hs", data, hsDark, hsLight, 2),
              chapterCard("loh", data, lohDark, lohLight, 3),
              chapterCard("mom", data, momDark, momLight, 4),
              chapterCard("m", data, mDark, mLight, 5),
              chapterCard("mgs", data, mgsDark, mgsLight, 6),
              chapterCard("ma", data, maDark, maLight, 7),
              chapterCard("www", data, wwwDark, wwwLight, 8),
              chapterCard("o", data, oDark, oLight, 9),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            width: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(child: Image.asset("assets/images/icons/cmc.png"), onTap: () => _scrollToIndex(0)),
                GestureDetector(child: Image.asset("assets/images/icons/da.png"), onTap: () => _scrollToIndex(1)),
                GestureDetector(child: Image.asset("assets/images/icons/hs.png"), onTap: () => _scrollToIndex(2)),
                GestureDetector(child: Image.asset("assets/images/icons/loh.png"), onTap: () => _scrollToIndex(3)),
                GestureDetector(key: globalKey4, child: Image.asset("assets/images/icons/mom.png"), onTap: () => _scrollToIndex(4)),
                GestureDetector(child: Image.asset("assets/images/icons/m.png"), onTap: () => _scrollToIndex(5)),
                GestureDetector(child: Image.asset("assets/images/icons/mgs.png"), onTap: () => _scrollToIndex(6)),
                GestureDetector(child: Image.asset("assets/images/icons/ma.png"), onTap: () => _scrollToIndex(7)),
                GestureDetector(child: Image.asset("assets/images/icons/www.png"), onTap: () => _scrollToIndex(8)),
                GestureDetector(child: Image.asset("assets/images/icons/o.png"), onTap: () => _scrollToIndex(9)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget chapterCard(String chapterId, Map<String, dynamic> data, Color dark, Color light, int index) {
    Chapter chapter = getChapterWithId(_registry, chapterId);

    List<Widget> widgets = List();
    widgets.add(Text(
      "${chapter.name}",
      style: TextStyle(color: Colors.white),
    ));
    widgets.addAll(getPagesIds(chapter).map((p) => pageCard(p, chapter, light, data, dark)));

    return AutoScrollTag(
      controller: controller,
      key: ValueKey(index),
      index: index,
      child: Card(
        color: dark,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  Widget pageCard(String pageId, Chapter chapter, Color lightColor, Map<String, dynamic> data, Color darkColor) {
    Page page = getPageWithId(chapter, pageId);
    String dropdownValue = getPrestigeLevelWithPageId(pageId, data);
    var key1;
    var key3;
    if (pageId == "hh") {
      key1 = globalKey1;
      key3 = globalKey3;
    }

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
            child: Text(
          "${page.name}",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        )),
        DropdownButton<String>(
          key: key3,
          value: dropdownValue,
          onChanged: (newValue) {
            Map<String, dynamic> newData = Map();
            page.foundables.forEach((foundable) {
              if (!_isUserAnonymous) {
                newData[foundable.id] = {'count': 0, 'level': getPrestigeLevelWithPrestigeValue(newValue)};
              } else {
                _userData.fragmentDataList[foundable.id]['count'] = 0;
                _userData.fragmentDataList[foundable.id]['level'] = getPrestigeLevelWithPrestigeValue(newValue);
              }
            });

            if (!_isUserAnonymous) {
              Firestore.instance.collection('userData').document(_userId).setData(newData, merge: true);
            } else {
              saveUserDataToPrefs(_userData);
            }
            setState(() {});
          },
          items: prestigeValues.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
        ),
        IconButton(
          key: key1,
          icon: Icon(
            Icons.edit,
            color: Colors.black,
          ),
          onPressed: () => _pushDialog(page, data, dropdownValue, darkColor, lightColor),
        )
      ],
    );

    List<Widget> widgets = List();
    widgets.add(header);
    widgets.addAll(getFoundablesIds(page).map((f) => foundableRow(f, page, data, dropdownValue, darkColor)));

    return Card(
      color: lightColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  Widget foundableRow(String foundableId, Page page, Map<String, dynamic> data, String dropdownValue, Color color) {
    Foundable foundable = getFoundableWithId(page, foundableId);
    int currentCount = data[foundableId]['count'];
    int currentLevel = data[foundableId]['level'];
    var intRequirement = getRequirementWithLevel(foundable, currentLevel);

    List<Widget> widgets = List();

    var key2;
    if (foundableId == "hh_1") {
      key2 = globalKey2;
    }

    widgets.addAll([
      Container(
        width: 50,
        height: 50,
        child: Image.asset("assets/images/foundables/$foundableId.png"),
      ),
      Expanded(child: Text(foundable.name)),
    ]);

    if (currentCount < intRequirement) {
      widgets.addAll([
        Container(
          width: 36,
          child: RaisedButton(
            key: key2,
            color: backgroundColor,
            padding: EdgeInsets.all(0),
            child: Text(
              "+",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _sendPlusEvent();
              _submit(_userId, foundable, (currentCount + 1).toString(), intRequirement);
            },
          ),
        ),
      ]);

      widgets.add(
          Container(
            alignment: Alignment.center,
            width: 90,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$currentCount / $intRequirement",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              color: Colors.transparent,
              elevation: 0,
            ),
          )
      );
    } else {
      widgets.add(
          Container(
            alignment: Alignment.center,
            width: 90,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$currentCount / $intRequirement",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: color,
            ),
          )
      );
    }

    return Row(
      children: widgets,
    );
  }

  _pushDialog(Page page, Map<String, dynamic> data, String dropdownValue, Color darkColor, Color lightColor) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return PageEditDialog(page, data, dropdownValue, darkColor, lightColor, _isUserAnonymous, _userId, _userData, callback, _analytics);
        }));
  }

  callback() {
    setState(() { });
  }

  _submit(String userId, Foundable foundable, String newValue, int requirement) {
    var newInt = int.tryParse(newValue) ?? 0;

    if (!_isUserAnonymous) {
      Firestore.instance.collection('userData').document(userId).setData({
        foundable.id: {'count': newInt}
      }, merge: true);
    } else {
      _userData.fragmentDataList[foundable.id]['count'] = newInt;
      saveUserDataToPrefs(_userData).then((value) {
        setState(() {});
      });
    }
  }

  Future _scrollToIndex(int index) async {
    _sendScrollToEvent(index);
    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
  }

  _sendPlusEvent() async {
    await _analytics.logEvent(
      name: 'click_plus_one_fragment',
    );
  }

  _sendScrollToEvent(int value) async {
    await _analytics.logEvent(
      name: 'scroll_to',
      parameters: <String, dynamic>{'value': value},
    );
  }

  void showTutorial() {
    TutorialCoachMark(context, targets: targets, colorShadow: Colors.brown, textSkip: "SKIP", paddingFocus: 4, opacityShadow: 0.8, finish: () {
      print("finish");
    }, clickTarget: (target) {
      print(target);
    }, clickSkip: () {
      print("skip");
    })
      ..show();
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        showTutorial();
        setTutorialShown();
      }
    });
  }

  Future<void> setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorialShown = true;
    await prefs.setBool('tutorialRegistry', true);
  }

  _getTutorialInfoFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tutorialRegistryShown = prefs.getBool('tutorialRegistry') ?? false;
    setState(() {
      _tutorialShown = tutorialRegistryShown;
    });
  }
}
