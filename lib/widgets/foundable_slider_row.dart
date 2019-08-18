import 'package:flutter/material.dart';
import 'package:registry_helper_for_wu/data/data.dart';

import '../main.dart';

class FoundableSliderRow extends StatefulWidget {
  final String foundableId;
  final Page page;
  Map<String, dynamic> data;
  String dropdownValue;
  final Color color;

  FoundableSliderRow(this.foundableId, this.page, this.data, this.dropdownValue, this.color);

  @override
  State<StatefulWidget> createState() => FoundableSliderRowState();
}

class FoundableSliderRowState extends State<FoundableSliderRow> {

  double _currentCount;
  double _requirement;
  Foundable _foundable;

  @override
  void initState() {
    super.initState();

    _foundable = getFoundableWithId(widget.page, widget.foundableId);

    int currentCount = widget.data[widget.foundableId]['count'];
    int currentLevel = widget.data[widget.foundableId]['level'];
    var intRequirement = getRequirementWithLevel(_foundable, currentLevel);

    _currentCount = currentCount.toDouble();
    _requirement = intRequirement.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Text("${_foundable.name}: ${_currentCount.round()}/${_requirement.round()}"),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 36,
              child: RaisedButton(
                color: backgroundColor,
                padding: EdgeInsets.all(0),
                child: Text(
                  "-",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    if (_currentCount > 0) _currentCount--;
                  });
                },
              ),
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: _requirement,
                value: _currentCount,
                divisions: _requirement.round(),
                activeColor: widget.color,
                inactiveColor: Colors.grey,
                label: _currentCount.round().toString(),
                onChanged: (newValue) {
                  setState(() {
                    _currentCount = newValue;
                  });
                },
              ),
            ),
            Container(
              width: 36,
              child: RaisedButton(
                color: backgroundColor,
                padding: EdgeInsets.all(0),
                child: Text(
                  "+",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    if (_currentCount < _requirement) _currentCount++;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

}