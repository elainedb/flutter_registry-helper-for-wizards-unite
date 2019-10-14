import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import 'foundable_slider_row.dart';

class PageEditDialog extends StatefulWidget {
  Function registryCallback;
  final Page page;
  Map<String, dynamic> data;
  String dropdownValue;
  final Color darkColor;
  final Color lightColor;
  bool isUserAnonymous;
  String userId;
  UserData userData;
  final FirebaseAnalytics analytics;

  PageEditDialog(this.page, this.data, this.dropdownValue, this.darkColor, this.lightColor, this.isUserAnonymous, this.userId, this.userData, this.registryCallback, this.analytics);

  @override
  State<StatefulWidget> createState() => PageEditDialogState();

}

class PageEditDialogState extends State<PageEditDialog> {
  Map<String, FoundableSliderRow> widgetMap = Map();
  Map<String, double> foundableCount = Map();
  List<Widget> widgets = List();

  @override
  void initState() {
    super.initState();

    getFoundablesIds(widget.page).forEach((f) {
      int currentCount = widget.data[f]['count'];

      widgetMap[f] = FoundableSliderRow(f, widget.page, widget.data, widget.dropdownValue, widget.darkColor, callback);
      foundableCount[f] = currentCount.toDouble();
    });

    widgets.addAll(widgetMap.values);

    widgets.add(
        FloatingActionButton.extended(
          backgroundColor: AppColors.backgroundColor,
          onPressed: () {
            _submitPage();
          },
          label: const Text("Submit"),
          icon: Icon(Icons.send),
        )
    );
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
              )
          ),
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

  _submitPage() {
    Map<String, dynamic> newData = Map();
    foundableCount.forEach((id, count) {
      newData[id] = {'count': count.truncate()};
    });

    if (!widget.isUserAnonymous) {
      Firestore.instance.collection('userData').document(widget.userId).setData(
          newData, merge: true);
    } else {
      foundableCount.forEach((id, count) {
        widget.userData.fragmentDataList[id]['count'] = count.truncate();
      });

      saveUserDataToPrefs(widget.userData).then((value) {
        widget.registryCallback();
      });
    }
    _sendSubmitPageEvent();

    Navigator.pop(context);
  }

  _sendSubmitPageEvent() async {
    await widget.analytics.logEvent(
      name: 'submit_page',
    );
  }
}