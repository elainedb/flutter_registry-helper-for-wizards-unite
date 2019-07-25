import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:registry_helper_for_wu/pages/charts.dart';

class StackedBarChart extends StatefulWidget {
  Function callback;
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarChart(this.seriesList, this.animate, this.callback);

  @override
  _StackedBarChartState createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    List<ChartBehavior> behaviors = List();
    behaviors.add(charts.LinePointHighlighter(
      showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.none,
      showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.none,
      defaultRadiusPx: 14,
    ));

    children.add(Container(
      height: 240,
      child: charts.BarChart(
        widget.seriesList,
        animate: widget.animate,
        barGroupingType: charts.BarGroupingType.stacked,
        primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
        domainAxis: charts.OrdinalAxisSpec(showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
        behaviors: behaviors,
        selectionModels: [
          charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
      ),
    ));

    return Column(children: children);
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum.first.datum as FoundablesData;
    widget.callback(selectedDatum);
  }
}
