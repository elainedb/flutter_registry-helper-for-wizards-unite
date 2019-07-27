import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import '../main.dart';

class HelperPage extends StatefulWidget {
  final Registry _registry;
  HelperPage(this._registry);

  @override
  State<StatefulWidget> createState() => HelperPageState(_registry);
}

class HelperPageState extends State<HelperPage> {
  final Registry _registry;
  HelperPageState(this._registry);

  String _dropdownValue;
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

    _dropdownValue = sortValues[0];
  }

  @override
  Widget build(BuildContext context) {
    if (_userId != null) {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              List<Widget> widgets = List();
              widgets.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'A summary of missing foundables from your Registry are listed below. Keep your data updated on "My Registry" page.',
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
                      ),
                      child: DropdownButton<String>(
                        value: _dropdownValue,
                        onChanged: (newValue) {
                          setState(() {
                            _dropdownValue = newValue;
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
                var missingTraces = getMissingTracesForChapter(chapter, snapshot.data);
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
                chapterRowsMap[_chapterRow(chapterForDisplay, missingTraces)] = value;
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
            } else
              return Center(
                child: Text("Loading"),
              );
          });
    } else
      return Center(child: Text("Loading"));
  }

  Widget _chapterRow(ChapterForDisplay chapterForDisplay, MissingTraces missingTraces) {

    return Card(
      color: chapterForDisplay.lightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 75,
              child: Image.asset("images/traces_transparent/${chapterForDisplay.id}.png"),
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
            child: Text(
              text,
              textAlign: TextAlign.center,
            )),
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
