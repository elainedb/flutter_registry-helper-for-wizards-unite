import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/bottom_bar_nav.dart';

class HelperPage extends StatefulWidget {
  final Registry _registry;
  HelperPage(this._registry);

  @override
  State<StatefulWidget> createState() => HelperPageState(_registry);
}

class HelperPageState extends State<HelperPage> {
  final Registry _registry;
  HelperPageState(this._registry);

  String _userId;

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
  }

  @override
  Widget build(BuildContext context) {
    if (_userId != null) {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  _chapterRow("cmc", cmcDark, cmcLight, snapshot.data),
                  _chapterRow("da", daDark, daLight, snapshot.data),
                  _chapterRow("hs", hsDark, hsLight, snapshot.data),
                  _chapterRow("loh", lohDark, lohLight, snapshot.data),
                  _chapterRow("mom", momDark, momLight, snapshot.data),
                  _chapterRow("m", mDark, mLight, snapshot.data),
                  _chapterRow("mgs", mgsDark, mgsLight, snapshot.data),
                  _chapterRow("ma", maDark, maLight, snapshot.data),
                  _chapterRow("www", wwwDark, wwwLight, snapshot.data),
                  _chapterRow("o", oDark, oLight, snapshot.data),
                ],
              );
            } else
              return Center(
                child: Text("Loading"),
              );
          });
    } else
      return Center(child: Text("Loading"));
  }

  Widget _chapterRow(String chapterId, Color dark, Color light, DocumentSnapshot snapshot) {
    var chapter = getChapterWithId(_registry, chapterId);
    var missingTraces = getMissingTracesForChapter(chapter, snapshot);

    return Card(
      color: light,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 75,
              child: Image.asset("images/traces_transparent/${chapterId}.png"),
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
            width: 16,
            child: Text(text, textAlign: TextAlign.center,)),
        ],
      );
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
