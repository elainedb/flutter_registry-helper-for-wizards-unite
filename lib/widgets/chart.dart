import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StackedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarChart(this.seriesList, {this.animate});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      child: charts.BarChart(
        seriesList,
        animate: animate,
        barGroupingType: charts.BarGroupingType.stacked,
        primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
        domainAxis: charts.OrdinalAxisSpec(showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
      ),
    );
  }
}