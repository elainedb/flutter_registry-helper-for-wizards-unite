import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import '../../pages/4_charts/chart.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/registry_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/utils.dart';
import '../../resources/i18n/app_strings.dart';

Widget getChartForChapter(Map<String, dynamic> data, String chapterId, String dark, String light, GlobalKey globalKey1, GlobalKey globalKey2, Function callback) {
  final registryStore = GetIt.instance<RegistryStore>();
  var chapter = getChapterWithId(registryStore.registry, chapterId);
  var totalList = List<FoundablesData>();
  var returnedList = List<FoundablesData>();
  var key;
  if (chapterId == "cmc") key = globalKey1;

  chapter.pages.forEach((page) {
    page.foundables.forEach((foundable) {
      var level = data[foundable.id]["level"];
      var total = getRequirementWithLevel(foundable, level);
      var returned = data[foundable.id]["count"];
      var remainder = total - returned;

      totalList.add(FoundablesData(foundable.id, foundable.id.i18n(), remainder));
      returnedList.add(FoundablesData(foundable.id, foundable.id.i18n(), returned));
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
        chapter.id.i18n(),
        style: AppStyles.chartsTitle(Color(hexToInt(light))),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (chartData.elementAt(0).data.length * 30).toDouble(),
          child: Stack(
            key: key,
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              getPageSeparators(chapter),
              StackedBarChart(chartData, true, callback),
              Container(
                margin: AppStyles.chartsInsets,
                child: getHowToCatchForChapter(chapter, globalKey2),
              ),
            ],
          ),
        ),
      ),
      Container(
        height: AppDimens.megaSize,
      ),
    ],
  );
}

Widget getHowToCatchForChapter(Chapter chapter, GlobalKey globalKey2) {
  final userDataStore = GetIt.instance<UserDataStore>();
  List<Widget> list = List();
  List<Widget> listPlaced = List();
  var key;
  if (chapter.id == "cmc") key = globalKey2;

  chapter.pages.forEach((page) {
    page.foundables.forEach((foundable) {
      bool isPlaced = userDataStore.data[foundable.id]['placed'];
      list.add(SizedBox(width: AppDimens.mediumSize, child: getIconWithFoundable(foundable, AppDimens.mediumSize)));
      listPlaced.add(
        Icon(
          Icons.stars,
          color: isPlaced ? AppColors.placedStar : AppColors.notPlacedStar,
          size: AppDimens.largeSize,
        ),
      );
    });
  });

  Padding howToWidget = Padding(
    padding: AppStyles.chartsHowToCatchInsets,
    child: Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: list,
    ),
  );

  Padding placedWidget = Padding(
    padding: AppStyles.chartsPlacedInsets,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: listPlaced,
    ),
  );

  List<Widget> childrenList = List();
  if (globalKey2 != null) {
    childrenList.add(howToWidget);
  }
  childrenList.add(placedWidget);

  return Column(
    children: childrenList,
  );
}

Widget getPageSeparators(Chapter chapter) {
  List<Widget> list = List();

  chapter.pages.forEach((page) {
    page.foundables.forEach((foundable) {
      var color = AppColors.backgroundColor;
      if (foundable.id.contains("_1")) {
        color = AppColors.chartsSeparatorColor;
      }

      Widget w = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Flex(
            children: List.generate(AppDimens.dashCount, (_) {
              return Column(
                children: <Widget>[
                  SizedBox(
                    width: AppDimens.dashWidth,
                    height: AppDimens.dashHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
                  ),
                  Container(
                    height: AppDimens.nanoSize,
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
        padding: AppStyles.chartsSeparatorsInsets,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: list,
        ),
      ),
      Container(
        height: AppDimens.largeSize,
      ),
    ],
  );
}

class FoundablesData {
  final String id;
  final String name;
  final int count;

  FoundablesData(this.id, this.name, this.count);
}