import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:share/share.dart';

import '../store/authentication.dart';
import '../resources/i18n/app_strings.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../utils/fanalytics.dart';
import '../widgets/version.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage();

  @override
  Widget build(BuildContext context) {
    final authentication = GetIt.instance<Authentication>();
    final analytics = GetIt.instance<FAnalytics>();

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;

    authentication.getEmail();

    return Material(
      color: AppColors.backgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Image.asset(
              "assets/images/old_books.png",
              width: width,
            ),
            bottom: 0,
          ),
          Positioned(
            child: Container(
              color: AppColors.transparentBlackCardColor,
            ),
            bottom: 0,
            top: 0,
            left: 0,
            right: 0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: FloatingActionButton.extended(
                  heroTag: "share_button",
                  backgroundColor: AppColors.fabBackgroundColor,
                  onPressed: () async {
                    Share.share("share_text".i18n());
                  },
                  label: Text("share_button".i18n()),
                  icon: Icon(Icons.share),
                ),
              ),
              Container(
                height: AppDimens.teraSize,
              ),
              Observer(builder: (_) {
                return Text(
                  "logged_as".i18n().replaceFirst("arg1", "${authentication.email}"),
                  style: AppStyles.lightContentText,
                );
              }),
              Container(
                height: AppDimens.megaSize,
              ),
              Center(
                child: FloatingActionButton.extended(
                  heroTag: "sign_out_button",
                  backgroundColor: AppColors.fabBackgroundColor,
                  onPressed: () async {
                    analytics.sendLogoutEvent();
                    authentication.signOut();
                    Navigator.of(context).pop();
                  },
                  label: Text("sign_out".i18n()),
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Center(child: VersionWidget()),
              Container(
                height: AppDimens.mediumSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

}
