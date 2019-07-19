import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../data/data.dart';

//https://www.wizardunite.com/2019/05/hpwu-foundables-and-traces.html
//https://github.com/hpwizardsunite-dev-contrib

final cmcDark = const Color(0xFF3B748C);
final cmcLight = const Color(0xFFB7DAEF);
final daDark = const Color(0xFF3A5C2A);
final daLight = const Color(0xFFCCEF85);
final hsDark = const Color(0xFF73442C);
final hsLight = const Color(0xFFE6936C);
final lohDark = const Color(0xFF646155);
final lohLight = const Color(0xFFE8E3C8);
final momDark = const Color(0xFF513C2B);
final momLight = const Color(0xFFE6AE61);
final mDark = const Color(0xFF273675);
final mLight = const Color(0xFF99B1F9);
final mgsDark = const Color(0xFF875F04);
final mgsLight = const Color(0xFFE6C976);
final maDark = const Color(0xFF612231);
final maLight = const Color(0xFFEF989A);
final wwwDark = const Color(0xFF13717E);
final wwwLight = const Color(0xFF72F9F9);
final oDark = const Color(0xFF382463);
final oLight = const Color(0xFFA77CE8);

class RegistryWidget extends StatefulWidget {
  final Registry _firebaseRegistry;
  RegistryWidget(this._firebaseRegistry);

  @override
  State<StatefulWidget> createState() => RegistryWidgetState(_firebaseRegistry);
}

class RegistryWidgetState extends State<RegistryWidget> {
  final Registry _firebaseRegistry;
  String _userId = "";
  Registry _registry;
  AutoScrollController controller;

  RegistryWidgetState(this._firebaseRegistry);

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
        });
      }
    });

    if (_firebaseRegistry != null) {
      setState(() {
        _registry = _firebaseRegistry;
      });
    } else {
      _getRegistryFromSharedPrefs();
    }

    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build for _userId = $_userId');

    return Builder(builder: (BuildContext context) {
      if (_userId.isEmpty) {
        return Center(
          child: Text("Loading"),
        );
      }
      return Row(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
                builder: (context, snapshot) {
                  return ListView(
                    scrollDirection: Axis.vertical,
                    controller: controller,
                    children: <Widget>[
                      chapterCard("cmc", snapshot, cmcDark, cmcLight, 0),
                      chapterCard("da", snapshot, daDark, daLight, 1),
                      chapterCard("hs", snapshot, hsDark, hsLight, 2),
                      chapterCard("loh", snapshot, lohDark, lohLight, 3),
                      chapterCard("mom", snapshot, momDark, momLight, 4),
                      chapterCard("m", snapshot, mDark, mLight, 5),
                      chapterCard("mgs", snapshot, mgsDark, mgsLight, 6),
                      chapterCard("ma", snapshot, maDark, maLight, 7),
                      chapterCard("www", snapshot, wwwDark, wwwLight, 8),
                      chapterCard("o", snapshot, oDark, oLight, 9),
                      RaisedButton(
                        child: const Text('Init Firebase'),
                        onPressed: () => _initUserData(_userId),
                      )
                    ],
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 42,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(child: Image.asset("images/cmc.png"), onTap: () => _scrollToIndex(0)),
                  GestureDetector(child: Image.asset("images/da.png"), onTap: () => _scrollToIndex(1)),
                  GestureDetector(child: Image.asset("images/hs.png"), onTap: () => _scrollToIndex(2)),
                  GestureDetector(child: Image.asset("images/loh.png"), onTap: () => _scrollToIndex(3)),
                  GestureDetector(child: Image.asset("images/mom.png"), onTap: () => _scrollToIndex(4)),
                  GestureDetector(child: Image.asset("images/m.png"), onTap: () => _scrollToIndex(5)),
                  GestureDetector(child: Image.asset("images/mgs.png"), onTap: () => _scrollToIndex(6)),
                  GestureDetector(child: Image.asset("images/ma.png"), onTap: () => _scrollToIndex(7)),
                  GestureDetector(child: Image.asset("images/www.png"), onTap: () => _scrollToIndex(8)),
                  GestureDetector(child: Image.asset("images/o.png"), onTap: () => _scrollToIndex(9)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget chapterCard(String chapterId, AsyncSnapshot<DocumentSnapshot> snapshot, Color dark, Color light, int index) {
    if (_registry != null && snapshot.hasData) {
      Chapter chapter = getChapterWithId(_registry, chapterId);

      List<Widget> widgets = List();
      widgets.add(Text(
        "${chapter.name}",
        style: TextStyle(color: Colors.white),
      ));
      widgets.addAll(getPagesIds(chapter).map((p) => pageCard(p, chapter, light, snapshot.data)));

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
    } else {
      return Center(
        child: Text("..."),
      );
    }
  }

  Widget pageCard(String pageId, Chapter chapter, Color light, DocumentSnapshot data) {
    Page page = getPageWithId(chapter, pageId);
    String dropdownValue = getPrestigeLevelWithPageId(pageId, data);

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("${page.name}"),
        DropdownButton<String>(
          value: dropdownValue,
          onChanged: (newValue) {
            page.foundables.forEach((foundable) {
              Firestore.instance.collection('userData').document(_userId).setData({
                foundable.id: {'count': 0, 'level': getPrestigeLevelWithPrestigeValue(newValue)}
              }, merge: true);
            });

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
    widgets.addAll(getFoundablesIds(page).map((f) => foundableRow(f, page, data, dropdownValue)));

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

  Widget foundableRow(String foundableId, Page page, DocumentSnapshot data, String dropdownValue) {
    Foundable foundable = getFoundableWithId(page, foundableId);
    String text = "";
    var _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submit(_userId, foundableId, text);
      }
    });

    return Row(
      children: <Widget>[
        Expanded(child: Text(foundable.name)),
        Container(
          width: 36,
          child: TextField(
            controller: TextEditingController(text: data[foundableId]['count'].toString()),
            onSubmitted: (newText) => {_submit(_userId, foundableId, newText)},
            onChanged: (newText) => text = newText,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
          ),
        ),
        Container(
          width: 30,
          child: Text(getFragmentRequirement(foundable, dropdownValue)),
        )
      ],
    );
  }

  _submit(String userId, String foundableId, String newValue) {
    var newInt = int.tryParse(newValue);
    if (newInt != null) {
      Firestore.instance.collection('userData').document(userId).setData({
        foundableId: {'count': newInt}
      }, merge: true);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter a number")));
      // TODO set textfield text to old value
    }
  }

  _initUserData(String userId) {
    List<String> ids = getAllFoundablesIds(_registry);

    Map<String, dynamic> map = Map();

    for (var id in ids) {
      map[id] = {'count': 0, 'level': 1};
    }

    Firestore.instance.collection('userData').document(userId).setData(map);
  }

  _getRegistryFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var registryString = prefs.getString('registry') ?? "";
    if (registryString.isNotEmpty) {
      setState(() {
        Map registryMap = jsonDecode(registryString);
        _registry = Registry.fromJson(registryMap) ?? null;
      });
    }
  }

  Future _scrollToIndex(int index) async {
    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
  }
}
