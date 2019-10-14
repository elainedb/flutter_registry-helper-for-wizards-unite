import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';

import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../widgets/version.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SettingsPage extends StatefulWidget {
  final FirebaseAnalytics _analytics;
  SettingsPage(this._analytics);

  @override
  State<StatefulWidget> createState() => SettingsPageState(_analytics);
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAnalytics _analytics;
  SettingsPageState(this._analytics);

  String _userEmail = "";

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _userEmail = user.email;
          if (user.isAnonymous) {
            _userEmail = "Anonymous";
          }
        });
      }
    });

    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;

    return Stack(
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
                backgroundColor: AppColors.fabBackgroundColor,
                onPressed: () async {
                  Share.share('Check out Registry Helper for Wizards Unite! Android: https://play.google.com/store/apps/details?id=elainedb.dev.registry_helper_for_wu / iOS: https://testflight.apple.com/join/lQjFo3iR');
                },
                label: const Text("Share the app with your friends!"),
                icon: Icon(Icons.share),
              ),
            ),
            Container(
              height: AppDimens.teraSize,
            ),
            Text(
              "Logged in as $_userEmail",
              style: AppStyles.lightContentText,
            ),
            Container(
              height: AppDimens.megaSize,
            ),
            Center(
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.fabBackgroundColor,
                onPressed: () async {
                  _firebaseSignOut();
                },
                label: const Text("Sign Out"),
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
    );
  }

  Future<void> _firebaseSignOut() async {
    _sendLogoutEvent();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  _sendLogoutEvent() async {
    await _analytics.logEvent(
      name: 'click_logout',
    );
  }
}
