import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../widgets/page_edit_dialog.dart';
import '../widgets/loading.dart';
import 'tutorial/my_registry_tutorial.dart';

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

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  GlobalKey globalKey4 = GlobalKey();
  bool _tutorialShown;

  @override
  void initState() {
    super.initState();
    MyRegistryTutorial.initTargets(globalKey1, globalKey2, globalKey3, globalKey4);
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
                return LoadingWidget();
            });
      }
    }
    return LoadingWidget();
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
              chapterCard("cmc", data, AppColors.cmcDark, AppColors.cmcLight, 0),
              chapterCard("da", data, AppColors.daDark, AppColors.daLight, 1),
              chapterCard("hs", data, AppColors.hsDark, AppColors.hsLight, 2),
              chapterCard("loh", data, AppColors.lohDark, AppColors.lohLight, 3),
              chapterCard("mom", data, AppColors.momDark, AppColors.momLight, 4),
              chapterCard("m", data, AppColors.mDark, AppColors.mLight, 5),
              chapterCard("mgs", data, AppColors.mgsDark, AppColors.mgsLight, 6),
              chapterCard("ma", data, AppColors.maDark, AppColors.maLight, 7),
              chapterCard("www", data, AppColors.wwwDark, AppColors.wwwLight, 8),
              chapterCard("o", data, AppColors.oDark, AppColors.oLight, 9),
            ],
          ),
        ),
        Padding(
          padding: AppStyles.registryIndexInsets,
          child: Container(
            width: AppDimens.registryIndexWidth,
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
      style: AppStyles.lightContentText,
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
          style: AppStyles.darkBoldContentText,
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
                style: AppStyles.darkContentText,
              ),
            );
          }).toList(),
        ),
        IconButton(
          key: key1,
          icon: Icon(
            Icons.edit,
            color: AppColors.darkColor,
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
        padding: AppStyles.miniInsets,
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
        width: AppDimens.mediumImageSize,
        height: AppDimens.mediumImageSize,
        child: Image.asset("assets/images/foundables/$foundableId.png"),
      ),
      Expanded(
          child: Text(
            foundable.name,
            style: AppStyles.darkContentText,
      )),
    ]);

    if (currentCount < intRequirement) {
      widgets.addAll([
        Container(
          width: AppDimens.gigaSize,
          child: RaisedButton(
            key: key2,
            color: AppColors.backgroundColor,
            padding: AppStyles.zeroInsets,
            child: Text(
              "+",
              style: AppStyles.quantityText,
            ),
            onPressed: () {
              _sendPlusEvent();
              _submit(_userId, foundable, (currentCount + 1).toString(), intRequirement);
            },
          ),
        ),
      ]);

      widgets.add(Container(
        alignment: Alignment.center,
        width: AppDimens.registryCounterWidth,
        child: Card(
          child: Padding(
            padding: AppStyles.miniInsets,
            child: Text(
              "$currentCount / $intRequirement",
              style: AppStyles.darkContentText,
            ),
          ),
          color: Colors.transparent,
          elevation: 0,
        ),
      ));
    } else {
      widgets.add(Container(
        alignment: Alignment.center,
        width: AppDimens.registryCounterWidth,
        child: Card(
          child: Padding(
            padding: AppStyles.miniInsets,
            child: Text(
              "$currentCount / $intRequirement",
              style: AppStyles.lightContentText,
            ),
          ),
          color: color,
        ),
      ));
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
    setState(() {});
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

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        MyRegistryTutorial.showTutorial(context);
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
