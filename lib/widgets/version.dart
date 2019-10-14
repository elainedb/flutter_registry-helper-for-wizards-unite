import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../resources/values/app_styles.dart';

class VersionWidget extends StatefulWidget {
  @override
  _VersionWidgetState createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();

    _getPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    var text = "";
    if (_packageInfo != null) {
      text = "version ${_packageInfo.version}";
    }
    return Text(
      text,
      style: AppStyles.lightContentText,
      textAlign: TextAlign.center,
    );
  }

  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }
}
