import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import '../main.dart';

class HelperPage extends StatefulWidget {
  final Registry _registry;
  String _initialSortValue;
  HelperPage(this._registry, this._initialSortValue);

  @override
  State<StatefulWidget> createState() => HelperPageState(_registry, _initialSortValue);
}

class HelperPageState extends State<HelperPage> {
  final Registry _registry;
  final String _initialSortValue;
  HelperPageState(this._registry, this._initialSortValue);

  String _dropdownValue;
  String _userId;
  int _initialIndex = 0;

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
    if (_initialSortValue != null) {
      _dropdownValue = _initialSortValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget._initialSortValue != null) {
      // fix for shortcut when page already displaying
      _dropdownValue = widget._initialSortValue;
      widget._initialSortValue = null;
    }

    if (_userId != null) {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DefaultTabController(
                initialIndex: _initialIndex,
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    flexibleSpace: SafeArea(
                      child: TabBar(
                        labelColor: Colors.amber,
                        indicatorColor: Colors.amber,
                        tabs: [
                          Tab(text: "Missing Foundables"),
                          Tab(text: "Insights"),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      _generalHelper(snapshot.data),
                      _insights(snapshot.data),
                    ],
                  ),
                  backgroundColor: backgroundColor,
                ),
              );
            } else
              return Center(
                child: Text("Loading"),
              );
          });
    } else
      return Center(child: Text("Loading"));
  }

  Widget _generalHelper(DocumentSnapshot snapshot) {
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
      var missingTraces = getMissingTracesForChapter(chapter, snapshot);
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
  }

  Widget _insights(DocumentSnapshot snapshot) {
    List<Widget> widgets = List();

    if (_getPagesWithOneOreTwoMissingWidgets(snapshot) != null) {
      widgets.addAll(_getPagesWithOneOreTwoMissingWidgets(snapshot));
    }
    if (_getNoClickWidgets(snapshot) != null) {
      widgets.addAll(_getNoClickWidgets(snapshot));
    }

    if (_getPagesWithOneOreTwoMissingWidgets(snapshot) == null && _getNoClickWidgets(snapshot) == null) {
      return Text("No insights for now!", style: TextStyle(color: Colors.white),);
    }

    return ListView(
      shrinkWrap: true,
      children: widgets,
    );
  }

  List<Widget> _getPagesWithOneOreTwoMissingWidgets(DocumentSnapshot snapshot) {
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
      List<AlmostCompletePage> almostCompletePages = getPagesWithOneOreTwoMissing(chapter, snapshot);
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
            child: Image.asset("images/traces_transparent/${chapterId}.png"),
          ),
          Container(
            width: 50,
            height: 50,
            child: Image.asset("images/foundables/${foundable.foundable.id}.png"),
          ),
          Container(
            width: 50,
            child: getIconWithFoundable(foundable.foundable, 30),
          ),
          Text("${foundable.remainingFragments} left", style: TextStyle(color: Colors.white),),
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

  List<Widget> _getNoClickWidgets(DocumentSnapshot snapshot) {
    List<ZeroTracesLeft> zeroTracesLeftList = List();
    chaptersForDisplay.forEach((chapterForDisplay) {
      var chapter = getChapterWithId(_registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, snapshot);
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
              child: Image.asset("images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
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
            child: Image.asset("images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
          ),
        ],
      );
    }
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
            width: 20,
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

class ZeroTracesLeft {
  final String chapterId;
  final String type;

  ZeroTracesLeft(this.chapterId, this.type);
}
