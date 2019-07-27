import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/utils/utils.dart';
import 'package:registry_helper_for_wu/widgets/chart.dart';
import 'package:registry_helper_for_wu/bottom_bar_nav.dart';

import '../main.dart';

class ChartsPage extends StatefulWidget {
  final Registry _registry;
  ChartsPage(this._registry);

  @override
  State<StatefulWidget> createState() => ChartsPageState(_registry);
}

class ChartsPageState extends State<ChartsPage> {
  final Registry _registry;
  ChartsPageState(this._registry);

  String _userId;
  FoundablesData _selectedFoundableData;

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

  void callback(FoundablesData foundable) {
    setState(() {
      _selectedFoundableData = foundable;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId != null) {
      List<Widget> widgets = List();

      widgets.add(StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('userData').document(_userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Threat Level",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 8,
                            ),
                            getThreatLevelRow(Colors.grey, "Low"),
                            getThreatLevelRow(Colors.white, "Medium"),
                            getThreatLevelRow(Colors.yellow, "High"),
                            getThreatLevelRow(Colors.orange, "Severe"),
                            getThreatLevelRow(Colors.red, "Emergency"),
                          ],
                        ),
                        Container(
                          width: 24,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "How to catch",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 8,
                            ),
                            getHowToRow(Icons.pets, "Wild"),
                            getHowToRow(Icons.vpn_key, "Portkey / Wild"),
                            getHowToRow(Icons.flash_on, "Wizarding Challenges"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  getChartForChapter(snapshot.data, "cmc", cmcDarkStringHex, cmcLightStringHex),
                  getChartForChapter(snapshot.data, "da", daDarkStringHex, daLightStringHex),
                  getChartForChapter(snapshot.data, "hs", hsDarkStringHex, hsLightStringHex),
                  getChartForChapter(snapshot.data, "loh", lohDarkStringHex, lohLightStringHex),
                  getChartForChapter(snapshot.data, "mom", momDarkStringHex, momLightStringHex),
                  getChartForChapter(snapshot.data, "m", mDarkStringHex, mLightStringHex),
                  getChartForChapter(snapshot.data, "mgs", mgsDarkStringHex, mgsLightStringHex),
                  getChartForChapter(snapshot.data, "ma", maDarkStringHex, maLightStringHex),
                  getChartForChapter(snapshot.data, "www", wwwDarkStringHex, wwwLightStringHex),
                  getChartForChapter(snapshot.data, "o", oDarkStringHex, oLightStringHex),
                ],
              );
            } else
              return Center(
                child: Text("Loading"),
              );
          }));

      if (_selectedFoundableData != null) {
        widgets.add(
            GestureDetector(
              onTap: _deleteFoundable,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 24,
                  ),
                  Card(
                    color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset("images/foundables/${_selectedFoundableData.id}.png"),
                            ),
                            Text(
                              "${_selectedFoundableData.name}",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
        );
      }

      return Stack(
        alignment: AlignmentDirectional.topEnd,
        children: widgets,
      );
    } else
      return Center(child: Text("Loading"));
  }

  Widget getChartForChapter(DocumentSnapshot snapshot, String chapterId, String dark, String light) {
    var chapter = getChapterWithId(_registry, chapterId);
    var totalList = List<FoundablesData>();
    var returnedList = List<FoundablesData>();

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        var level = snapshot[foundable.id]["level"];
        var total = getRequirementWithLevel(foundable, level);
        var returned = snapshot[foundable.id]["count"];
        var remainder = total - returned;

        totalList.add(FoundablesData(foundable.id, foundable.name, remainder));
        returnedList.add(FoundablesData(foundable.id, foundable.name, returned));
      });
    });

    List<charts.Series<FoundablesData, String>> chartData = [
      charts.Series<FoundablesData, String>(
        id: 'Total',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: totalList,
        colorFn: (_, __) => charts.Color.fromHex(code: light),
      ),
      charts.Series<FoundablesData, String>(
        id: 'Returned',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: returnedList,
        colorFn: (_, __) => charts.Color.fromHex(code: dark),
      )
    ];

    return Column(
      children: <Widget>[
        Text(
          chapter.name,
          style: TextStyle(color: Color(hexToInt(light))),
        ),
        Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            getPageSeparators(chapter),
            StackedBarChart(chartData, true, callback),
            getHowToCatchForChapter(chapter),
          ],
        ),
        Container(
          height: 24,
        ),
      ],
    );
  }

  Widget getHowToCatchForChapter(Chapter chapter) {
    List<Widget> list = List();

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        list.add(getIconWithFoundable(foundable));
      });
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: list,
      ),
    );
  }

  Widget getPageSeparators(Chapter chapter) {
    List<Widget> list = List();

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        var color = backgroundColor;
        if (foundable.id.contains("_1")) {
          color = Colors.white;
        }

        Widget w = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final dashWidth = 2.0;
            final dashHeight = 8.0;
            final dashCount = 20;
            return Flex(
              children: List.generate(dashCount, (_) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      width: dashWidth,
                      height: dashHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: color),
                      ),
                    ),
                    Container(
                      height: 2,
                    )
                  ],
                );
              }),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
            );
          },
        );

        list.add(w);
      });
    });

    list.removeAt(0);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: list,
          ),
        ),
        Container(
          height: 20,
        ),
      ],
    );
  }

  Widget getThreatLevelRow(Color color, String text) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.brightness_1,
          color: color,
        ),
        Container(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget getHowToRow(IconData iconData, String text) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          color: Colors.white,
        ),
        Container(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  _deleteFoundable() {
    setState(() {
      _selectedFoundableData = null;
    });
  }
}

class FoundablesData {
  final String id;
  final String name;
  final int count;

  FoundablesData(this.id, this.name, this.count);
}
