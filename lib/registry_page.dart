import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/data.dart';

const cmcColor1 = Color.fromRGBO(73, 113, 136, 1);
const cmcColor2 = Color.fromRGBO(203, 235, 252, 1);

class RegistryPage extends StatefulWidget {
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => RegistryPageState();
}

class RegistryPageState extends State<RegistryPage> {
  String _userId = "";
  Registry _registry;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
        });
      }
    });

    _getRegistry();
  }

  @override
  Widget build(BuildContext context) {
    print('build for _userId = $_userId');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        if (_userId.isEmpty) {
          return Center(
            child: Text("Loading"),
          );
        }
        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('userData')
                .document(_userId)
                .snapshots(),
            builder: (context, snapshot) {
              return ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  chapterCard("cmc", snapshot),
                  RaisedButton(
                    child: const Text('Init Firebase'),
                    onPressed: () => _initUserData(_userId),
                  )
                ],
              );
            });
      }),
    );
  }

  Widget chapterCard(
      String chapterId, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (_registry != null) {
      Chapter chapter = getChapterWithId(_registry, chapterId);

      List<Widget> widgets = List();
      widgets.add(Text(
        "${chapter.name}",
        style: TextStyle(color: Colors.white),
      ));
      widgets.addAll(
          getPagesIds(chapter).map((p) => pageCard(p, chapter, snapshot.data)));

      return Card(
        color: cmcColor1,
        child: Column(
          children: widgets,
        ),
      );
    } else {
      return Center(
        child: Text("..."),
      );
    }
  }

  Widget pageCard(String pageId, Chapter chapter, DocumentSnapshot data) {
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

          setState(() { });

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
    widgets.addAll(
        getFoundablesIds(page).map((f) => foundableRow(f, page, data, dropdownValue)));

    return Card(
      color: cmcColor2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  Widget foundableRow(
      String foundableId, Page page, DocumentSnapshot data, String dropdownValue) {
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
            controller: TextEditingController(
                text: data[foundableId]['count'].toString()),
            onSubmitted: (newText) => {_submit(_userId, foundableId, newText)},
            onChanged: (newText) => text = newText,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
          ),
        ),
        Container(
          width: 28,
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
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter a number")));
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

  _getRegistry() {
    Firestore.instance
        .collection("registryData")
        .snapshots()
        .forEach((snapshot) async {
      if (snapshot != null) {
        List<Chapter> chapterList = List();
        for (var chapter in snapshot.documents) {
          String chapterId = chapter.documentID;
          String chapterName = chapter.data["name_en"];
          List<Page> pageList = List();
          await chapter.reference
              .collection("pages")
              .getDocuments()
              .then((pages) async {
            if (pages != null) {
              for (var page in pages.documents) {
                String pageId = page.documentID;
                String pageName = page.data["name_en"];
                List<Foundable> foundableList = List();
                await page.reference
                    .collection("foundables")
                    .getDocuments()
                    .then((foundables) {
                  if (foundables != null) {
                    for (var foundable in foundables.documents) {
                      foundableList.add(Foundable(
                          foundable.documentID,
                          foundable.data['name_en'],
                          foundable.data['frag_req1'],
                          foundable.data['frag_req2'],
                          foundable.data['frag_req3'],
                          foundable.data['frag_req4']));
                    }
                  }
                });
                print("pageList.add(Page(pageId, pageName, foundableList));");
                pageList.add(Page(pageId, pageName, foundableList));
              }
            }
          });
          print("chapterList.add(Chapter(chapterId, chapterName, pageList));");
          chapterList.add(Chapter(chapterId, chapterName, pageList));
        }
        print("registry = Registry(chapterList);");
        setState(() {
          print("setstate");
          _registry = Registry(chapterList);
        });
      }
    });
  }
}

String _handleSignIn() {
  /*bool loggedIn = false;
  var userUid;
  FirebaseAuth.instance.currentUser().then((user) {
    if (user != null) {
      userUid = user.uid;
      loggedIn = true;
    }
    print('trsting $loggedIn');

  });*/

  return "";
}
