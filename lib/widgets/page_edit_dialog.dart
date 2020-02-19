import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../store/authentication.dart';
import '../store/user_data_store.dart';
import '../utils/fanalytics.dart';
import 'foundable_slider_row.dart';

class PageEditDialog extends StatefulWidget {
  final Page page;
  final String dropdownValue;
  final Color darkColor;
  final Color lightColor;

  PageEditDialog(this.page, this.dropdownValue, this.darkColor, this.lightColor);

  @override
  State<StatefulWidget> createState() => PageEditDialogState();
}

class PageEditDialogState extends State<PageEditDialog> {
  Map<String, FoundableSliderRow> widgetMap = Map();
  Map<String, double> foundableCount = Map();
  List<Widget> widgets = List();

  final authentication = GetIt.instance<Authentication>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();

  @override
  void initState() {
    super.initState();

    getFoundablesIds(widget.page).forEach((f) {
      int currentCount = userDataStore.data[f]['count'];

      widgetMap[f] = FoundableSliderRow(callback, f, widget.page, widget.dropdownValue, widget.darkColor);
      foundableCount[f] = currentCount.toDouble();
    });

    widgets.addAll(widgetMap.values);

    widgets.add(FloatingActionButton.extended(
      backgroundColor: AppColors.backgroundColor,
      onPressed: () {
        userDataStore.submitNewPage(foundableCount).then((_) {
          analytics.sendSubmitPageEvent();
          Navigator.pop(context);
        });
      },
      label: const Text("Submit"),
      icon: Icon(Icons.send),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Card(
          margin: AppStyles.mediumInsets,
          color: widget.lightColor,
          shape: ContinuousRectangleBorder(
              side: BorderSide(
            color: widget.darkColor,
            width: AppDimens.miniSize,
          )),
          child: Padding(
            padding: AppStyles.mediumInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ),
        ),
      ],
    );
  }

  void callback(String foundableId, double newValue) {
    setState(() {
      foundableCount[foundableId] = newValue;
//      print("foundableCount for $foundableId = $newValue");
    });
  }
}
