import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'resources/values/app_colors.dart';
import 'resources/values/app_dimens.dart';
import 'resources/values/app_styles.dart';
import 'store/authentication.dart';
import 'store/signin_image.dart';
import 'utils/fanalytics.dart';
import 'widgets/version.dart';

class SignInWidget extends StatefulWidget {
  SignInWidget();

  @override
  State<StatefulWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> with TickerProviderStateMixin {
  SignInWidgetState();

  AnimationController _controller;

  var isIOS13 = false;

  @override
  void initState() {
    super.initState();

    final signInImage = GetIt.instance<SignInImage>();

    signInImage.loadImage();

    FAnalytics.analytics.setCurrentScreen(
      screenName: "SignInPage",
    );

    _controller = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setIsIOS13();
  }

  @override
  Widget build(BuildContext context) {
    final signInImage = GetIt.instance<SignInImage>();
    final authentication = GetIt.instance<Authentication>();
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;

    return Builder(builder: (BuildContext context) {
      return Stack(
        children: <Widget>[
          Observer(
            builder: (_) {
              if (signInImage.image != null) {
                double imageHeight = signInImage.image.height.roundToDouble();
                double imageWidth = signInImage.image.width.roundToDouble();
                double scale = height / imageHeight;
                double tweenBegin = -(imageWidth * scale) / 2;
                return AnimatedBuilder(
                  animation: Tween(begin: tweenBegin, end: 0).animate(_controller),
                  child: CustomPaint(
                    size: Size(imageWidth, imageHeight),
                    painter: MyPainter(signInImage.image, scale),
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
              _signInWidget(),
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

  Widget _signInWidget() {
    final authentication = GetIt.instance<Authentication>();

    List<Widget> widgets = List();
    widgets.addAll([
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
          authentication.signInWithGoogle();
        },
        label: const Text('Sign in with Google'),
        icon: Icon(Icons.account_circle),
      )
    ]);

    if (isIOS13) {
      widgets.addAll([
        Container(
          height: AppDimens.mediumSize,
        ),
        FloatingActionButton.extended(
          backgroundColor: AppColors.fabBackgroundColor,
          onPressed: () async {
            authentication.signInWithApple();
          },
          label: const Text('Sign in with Apple'),
          icon: Icon(Icons.account_circle),
        )
      ]);
    }

    return Card(
      margin: AppStyles.miniInsets,
      color: AppColors.transparentBlackCardColor,
      child: Padding(
        padding: AppStyles.mediumInsets,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  void _setIsIOS13() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      DeviceInfoPlugin().iosInfo.then((info) {
        var version = info.systemVersion;

        if (int.parse(version.split(".")[0]) >= 13) {
          setState(() {
            isIOS13 = true;
          });
        }
      });
    }
  }

  _sendLoginEvent(String type) async {
    await FAnalytics.analytics.logEvent(
      name: 'click_login',
      parameters: <String, dynamic>{'value': type},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
