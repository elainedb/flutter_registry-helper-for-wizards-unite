import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../store/user_data_store.dart';
import '../resources/i18n/app_strings.dart';

class FoundableSliderRow extends StatefulWidget {
  final Function callback;
  final String foundableId;
  final WUPage page;
  final String dropdownValue;
  final Color color;

  FoundableSliderRow(this.callback, this.foundableId, this.page, this.dropdownValue, this.color);

  @override
  State<StatefulWidget> createState() => FoundableSliderRowState();
}

class FoundableSliderRowState extends State<FoundableSliderRow> {
  double _currentCount;
  double _requirement;
  Foundable _foundable;

  final userDataStore = GetIt.instance<UserDataStore>();

  @override
  void initState() {
    super.initState();

    _foundable = getFoundableWithId(widget.page, widget.foundableId);

    int currentCount = userDataStore.data[widget.foundableId]['count'];
    int currentLevel = userDataStore.data[widget.foundableId]['level'];
    var intRequirement = getRequirementWithLevel(_foundable, currentLevel);

    _currentCount = currentCount.toDouble();
    _requirement = intRequirement.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "${_foundable.id.i18n()}: ${_currentCount.round()}/${_requirement.round()}",
          style: AppStyles.darkContentText,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: AppDimens.gigaSize,
              child: RaisedButton(
                color: AppColors.backgroundColor,
                padding: AppStyles.zeroInsets,
                child: Text(
                  "-",
                  style: AppStyles.quantityText,
                ),
                onPressed: () {
                  if (_currentCount > 0) {
                    double newValue = _currentCount - 1;
                    widget.callback(_foundable.id, newValue);
                    setState(() {
                      _currentCount--;
                    });
                  }
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
                  widget.callback(_foundable.id, newValue);
                  setState(() {
                    _currentCount = newValue;
                  });
                },
              ),
            ),
            Container(
              width: AppDimens.gigaSize,
              child: RaisedButton(
                color: AppColors.backgroundColor,
                padding: AppStyles.zeroInsets,
                child: Text(
                  "+",
                  style: AppStyles.quantityText,
                ),
                onPressed: () {
                  if (_currentCount < _requirement) {
                    double newValue = _currentCount + 1;
                    widget.callback(_foundable.id, newValue);
                    setState(() {
                      _currentCount = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
