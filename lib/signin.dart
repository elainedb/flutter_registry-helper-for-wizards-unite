import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'resources/i18n/app_strings.dart';
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

  final signInImage = GetIt.instance<SignInImage>();
  final authentication = GetIt.instance<Authentication>();
  final analytics = GetIt.instance<FAnalytics>();

  @override
  void initState() {
    super.initState();

    signInImage.loadImage();

    analytics.sendCurrentScreen("SignInPage");

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
                      "welcome".i18n(),
                      style: AppStyles.titleText,
                      textAlign: TextAlign.center,
                    ),
                    if (!kIsWeb) Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.orangeAccent,
                      period: Duration(seconds: 2),
                      child: Text(
                        "welcome".i18n(),
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
                        "try_out".i18n(),
                        style: AppStyles.mediumText,
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: AppDimens.mediumSize,
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: AppColors.fabBackgroundColor,
                        onPressed: () async {
                          analytics.sendLoginEvent("Anonymous");
                          authentication.signInAnonymous();
                        },
                        label: Text("sign_in_anon".i18n()),
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
              if (!kIsWeb) Center(child: VersionWidget()),
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
    List<Widget> widgets = List();
    widgets.addAll([
      Text(
        "backup_data".i18n(),
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
        label: Text("sign_in_google".i18n()),
        icon: Icon(Icons.account_circle),
      )
    ]);

    if (isIOS13) {
      widgets.addAll([
        Container(
          height: AppDimens.mediumSize,
        ),
        FlatButton(
            onPressed: () async {
              authentication.signInWithApple();
            },
            padding: EdgeInsets.all(0.0),
            child: Image.asset("image_apple_button".i18n())),
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
