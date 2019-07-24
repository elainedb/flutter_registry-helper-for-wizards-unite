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
                  getChartForChapter(snapshot.data, "cmc", cmcDarkStringHex, cmcLightStringHex), getHowToCatchForChapter("cmc"),
                  getChartForChapter(snapshot.data, "da", daDarkStringHex, daLightStringHex), getHowToCatchForChapter("da"),
                  getChartForChapter(snapshot.data, "hs", hsDarkStringHex, hsLightStringHex), getHowToCatchForChapter("hs"),
                  getChartForChapter(snapshot.data, "loh", lohDarkStringHex, lohLightStringHex), getHowToCatchForChapter("loh"),
                  getChartForChapter(snapshot.data, "mom", momDarkStringHex, momLightStringHex), getHowToCatchForChapter("mom"),
                  getChartForChapter(snapshot.data, "m", mDarkStringHex, mLightStringHex), getHowToCatchForChapter("m"),
                  getChartForChapter(snapshot.data, "mgs", mgsDarkStringHex, mgsLightStringHex), getHowToCatchForChapter("mgs"),
                  getChartForChapter(snapshot.data, "ma", maDarkStringHex, maLightStringHex), getHowToCatchForChapter("ma"),
                  getChartForChapter(snapshot.data, "www", wwwDarkStringHex, wwwLightStringHex), getHowToCatchForChapter("www"),
                  getChartForChapter(snapshot.data, "o", oDarkStringHex, oLightStringHex), getHowToCatchForChapter("o"),
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

  Widget getHowToCatchForChapter(String chapterId) {
    List<Widget> list = List();
    var chapter = getChapterWithId(_registry, chapterId);

    chapter.pages.forEach((page) {
      page.foundables.forEach((foundable) {
        list.add(getIconWithFoundable(foundable));
      });
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 42),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: list,
      ),
    );
  }

}

class FoundablesData {
  final String id;
  final int count;

  FoundablesData(this.id, this.count);
}
