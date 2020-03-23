import 'package:flutter/material.dart';

import '../resources/i18n/app_strings.dart';
import '../resources/values/app_styles.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "loading".i18n(),
        style: AppStyles.lightContentText,
      ),
    );
  }
}
