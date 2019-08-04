import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/bottom_bar_nav.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../main.dart';

class MyRegistryPage extends StatefulWidget {
  final Registry _registry;
  MyRegistryPage(this._registry);

  @override
  State<StatefulWidget> createState() => MyRegistryPageState(_registry);
}

class MyRegistryPageState extends State<MyRegistryPage> {
  final Registry _registry;
  MyRegistryPageState(this._registry);

  String _userId;
  AutoScrollController controller;
  bool _isUserAnonymous;
  UserData _userData;

  @override
  void initState() {
    super.initState();

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

  Widget registryWidget(Map<String, dynamic> data) {
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
                GestureDetector(child: Image.asset("images/icons/cmc.png"), onTap: () => _scrollToIndex(0)),
                GestureDetector(child: Image.asset("images/icons/da.png"), onTap: () => _scrollToIndex(1)),
                GestureDetector(child: Image.asset("images/icons/hs.png"), onTap: () => _scrollToIndex(2)),
                GestureDetector(child: Image.asset("images/icons/loh.png"), onTap: () => _scrollToIndex(3)),
                GestureDetector(child: Image.asset("images/icons/mom.png"), onTap: () => _scrollToIndex(4)),
                GestureDetector(child: Image.asset("images/icons/m.png"), onTap: () => _scrollToIndex(5)),
                GestureDetector(child: Image.asset("images/icons/mgs.png"), onTap: () => _scrollToIndex(6)),
                GestureDetector(child: Image.asset("images/icons/ma.png"), onTap: () => _scrollToIndex(7)),
                GestureDetector(child: Image.asset("images/icons/www.png"), onTap: () => _scrollToIndex(8)),
                GestureDetector(child: Image.asset("images/icons/o.png"), onTap: () => _scrollToIndex(9)),
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

  Widget pageCard(String pageId, Chapter chapter, Color light, Map<String, dynamic> data, Color color) {
    Page page = getPageWithId(chapter, pageId);
    String dropdownValue = getPrestigeLevelWithPageId(pageId, data);

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("${page.name}"),
        DropdownButton<String>(
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
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );

    List<Widget> widgets = List();
    widgets.add(header);
    widgets.addAll(getFoundablesIds(page).map((f) => foundableRow(f, page, data, dropdownValue, color)));

    return Card(
      color: light,
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
    String text = "";
    int currentCount = data[foundableId]['count'];
    int currentLevel = data[foundableId]['level'];
    var requirementForPrint = getFragmentRequirement(foundable, dropdownValue);
    var intRequirement = getRequirementWithLevel(foundable, currentLevel);

    var _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submit(_userId, foundable, text, intRequirement);
      }
    });

    List<Widget> widgets = List();

    widgets.addAll([
      Container(
        width: 50,
        height: 50,
        child: Image.asset("images/foundables/$foundableId.png"),
      ),
      Expanded(child: Text(foundable.name)),
    ]);

    if (currentCount < intRequirement) {
      widgets.addAll([
        Container(
          width: 36,
          child: RaisedButton(
            color: backgroundColor,
            padding: EdgeInsets.all(0),
            child: Text(
              "+",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _submit(_userId, foundable, (currentCount + 1).toString(), intRequirement),
          ),
        ),
        Container(
          width: 8,
        )
      ]);

      widgets.addAll([
        Container(
          width: 36,
          child: TextField(
            controller: TextEditingController(text: currentCount.toString()),
            onSubmitted: (newText) => {_submit(_userId, foundable, newText, intRequirement)},
            onChanged: (newText) => text = newText,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
          ),
        ),
        Container(
          width: 30,
          child: Text(requirementForPrint),
        )
      ]);
    } else {
      widgets.add(GestureDetector(
        onTap: () => _reset(_userId, foundable, intRequirement),
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
      ));
    }

    return Row(
      children: widgets,
    );
  }

  _submit(String userId, Foundable foundable, String newValue, int requirement) {
    var newInt = int.tryParse(newValue) ?? 0;
    if (newInt > requirement) {
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid number")));
      newInt = requirement;
    }

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

  _reset(String userId, Foundable foundable, int requirement) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Reset value?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  _submit(userId, foundable, "0", requirement);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future _scrollToIndex(int index) async {
    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
  }
}
