import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:registry_helper_for_wu/widgets/version.dart';
import 'package:shimmer/shimmer.dart';

import 'resources/values/app_colors.dart';
import 'resources/values/app_dimens.dart';
import 'resources/values/app_styles.dart';
import 'store/authentication.dart';
import 'store/signin_image.dart';

final Authentication authentication = Authentication();
final SignInImage signInImage = SignInImage();

class SignInWidget extends StatefulWidget {
  final FirebaseAnalytics _analytics;
  SignInWidget(this._analytics);

  @override
  State<StatefulWidget> createState() => SignInWidgetState(_analytics);
}

class SignInWidgetState extends State<SignInWidget> with TickerProviderStateMixin {
  final FirebaseAnalytics _analytics;
  SignInWidgetState(this._analytics);

  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    signInImage.loadImage();

    _analytics.setCurrentScreen(
      screenName: "SignInPage",
    );

    _controller = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;

    return Builder(builder: (BuildContext context) {
      return Stack(
        children: <Widget>[
          Observer(
            builder: (_) {
              if (signInImage.actualImage != null) {
                double imageHeight = signInImage.actualImage.height.roundToDouble();
                double imageWidth = signInImage.actualImage.width.roundToDouble();
                double scale = height / imageHeight;
                double tweenBegin = -(imageWidth * scale) / 2;
                return AnimatedBuilder(
                  animation: Tween(begin: tweenBegin, end: 0).animate(_controller),
                  child: CustomPaint(
                    size: Size(imageWidth, imageHeight),
                    painter: MyPainter(signInImage.actualImage, scale),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(Tween(begin: tweenBegin, end: 0).animate(_controller).value, 0),
                      child: child,
                    );
                  },
                );
              }

              return Container();
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: AppStyles.mediumInsets,
                child: Stack(
                  children: <Widget>[
                    Text(
                      'Welcome to Registry Helper for Wizards Unite!',
                      style: AppStyles.titleText,
                      textAlign: TextAlign.center,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.orangeAccent,
                      period: Duration(seconds: 2),
                      child: Text(
                        'Welcome to Registry Helper for Wizards Unite!',
                        style: AppStyles.extraLargeBoldText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: AppStyles.miniInsets,
                color: AppColors.transparentBlackCardColor,
                child: Padding(
                  padding: AppStyles.mediumInsets,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'In order to automatically backup your data, please sign in.',
                        style: AppStyles.mediumText,
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: AppDimens.mediumSize,
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: AppColors.fabBackgroundColor,
                        onPressed: () async {
                          _sendLoginEvent("Google");
                          authentication.signInWithGoogle();
                        },
                        label: const Text('Sign in with Google'),
                        icon: Icon(Icons.account_circle),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: AppStyles.miniInsets,
                color: AppColors.transparentBlackCardColor,
                child: Padding(
                  padding: AppStyles.mediumInsets,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'If you wish to try out first, you can sign in anonymously.',
                        style: AppStyles.mediumText,
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: AppDimens.mediumSize,
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: AppColors.fabBackgroundColor,
                        onPressed: () async {
                          _sendLoginEvent("Anonymous");
                          authentication.signInAnonymous();
                        },
                        label: const Text('Anonymous sign in'),
                        icon: Icon(Icons.help),
                      ),
                    ],
                  ),
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
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _sendLoginEvent(String type) async {
    await _analytics.logEvent(
      name: 'click_login',
      parameters: <String, dynamic>{'value': type},
    );
  }
}

class MyPainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  MyPainter(this.image, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    canvas.drawImage(image, Offset(0, 0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
