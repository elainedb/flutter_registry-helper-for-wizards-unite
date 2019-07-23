import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/widgets/chart.dart';

import '../main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class StatsPage extends StatefulWidget {
  final Registry _registry;
  StatsPage(this._registry);

  @override
  State<StatefulWidget> createState() => StatsPageState(_registry);
}

class StatsPageState extends State<StatsPage> {
  final Registry _registry;
  StatsPageState(this._registry);

  String _userId = "";

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
//          _updateWidgets();
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
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "cmc")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "da")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "hs")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "loh")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "mom")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "m")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "mgs")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "ma")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "www")), height: 240),
                  Container(child: StackedBarChart(getChapterSeries(snapshot.data, "o")), height: 240),
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

  List<charts.Series<FoundablesData, String>> getChapterSeries(DocumentSnapshot snapshot, String chapterId) {
    var chapter = getChapterWithId(_registry, chapterId);
    var totalList = List<FoundablesData>();
    var returnedList = List<FoundablesData>();

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        var level = snapshot[foundable.id]["level"];
        var total = getRequirementWithLevel(foundable, level);
        var returned = snapshot[foundable.id]["count"];
        var remainder = total - returned;

        totalList.add(FoundablesData(foundable.id, remainder));
        returnedList.add(FoundablesData(foundable.id, returned));
      });
    });

    return [
      charts.Series<FoundablesData, String>(
        id: 'Total',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: totalList,
      ),
      charts.Series<FoundablesData, String>(
        id: 'Returned',
        domainFn: (FoundablesData data, _) => data.id,
        measureFn: (FoundablesData data, _) => data.count,
        data: returnedList,
      )
    ];
  }
}

class FoundablesData {
  final String id;
  final int count;

  FoundablesData(this.id, this.count);
}
