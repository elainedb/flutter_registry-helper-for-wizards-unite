import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../pages/charts.dart';
import '../resources/values/app_dimens.dart';

class StackedBarChart extends StatefulWidget {
  final Function callback;
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

    List<charts.ChartBehavior> behaviors = List();
    behaviors.add(charts.LinePointHighlighter(
      showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.none,
      showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.none,
      defaultRadiusPx: 14,
    ));

    children.add(SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: AppDimens.chartsHeight,
        width: (widget.seriesList.elementAt(0).data.length * 30).toDouble(),
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
      ),
    ));

    return Column(children: children);
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum.first.datum as FoundablesData;
    widget.callback(selectedDatum);
  }
}
