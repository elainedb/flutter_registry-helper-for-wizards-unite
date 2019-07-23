import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/utils/utils.dart';
import 'package:registry_helper_for_wu/widgets/chart.dart';
import 'package:registry_helper_for_wu/widgets/registry.dart';

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
          });
    } else
      return Center(child: Text("Loading"));
  }

  Column getChartForChapter(DocumentSnapshot snapshot, String chapterId, String dark, String light) {
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

    List<charts.Series<FoundablesData, String>> chartData = [
      charts.Series<FoundablesData, String>(
          id: 'Total',
          domainFn: (FoundablesData data, _) => data.id,
          measureFn: (FoundablesData data, _) => data.count,
          data: totalList,
          colorFn: (_, __) => charts.Color.fromHex(code: light),
          displayName: ""),
      charts.Series<FoundablesData, String>(
          id: 'Returned',
          domainFn: (FoundablesData data, _) => data.id,
          measureFn: (FoundablesData data, _) => data.count,
          data: returnedList,
          colorFn: (_, __) => charts.Color.fromHex(code: dark),
          displayName: "")
    ];


      return Column(
      children: <Widget>[
        Text(chapter.name, style: TextStyle(color: Color(hexToInt(light))),),
        StackedBarChart(chartData),
      ],
    );
  }
}

class FoundablesData {
  final String id;
  final int count;

  FoundablesData(this.id, this.count);
}
