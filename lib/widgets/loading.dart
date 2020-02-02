import 'package:flutter/material.dart';

import '../resources/values/app_styles.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Loading...",
        style: AppStyles.lightContentText,
      ),
    );
  }
}
