import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:registry_helper_for_wu/widgets/version.dart';
import 'package:shimmer/shimmer.dart';

import 'resources/values/app_colors.dart';
import 'resources/values/app_dimens.dart';
import 'resources/values/app_styles.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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
  ui.Image image;
  double scale = 1;

  @override
  void initState() {
    super.initState();

    _loadImage();

    _controller = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double tweenBegin = 0;

    if (image != null) {
      scale = height / image.height;
      tweenBegin = -(image.width * scale) / 2;
      print("scale = $scale");
      print("height = $height");
      print("image.height = $image.height");
    }

    final animation = Tween(begin: tweenBegin, end: 0).animate(_controller);

    return Builder(builder: (BuildContext context) {
      return Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: animation,
            /*child: Transform.translate(
              offset: Offset(-50, 0),
              child: Image.asset(
                "images/background.jpg",
                fit: BoxFit.none,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,),
            ),*/
            child: image != null
                ? CustomPaint(
                    size: Size(image.width.roundToDouble(), image.height.roundToDouble()),
                    painter: MyPainter(image, scale),
                  )
                : Container(),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(animation.value, 0),
                child: child,
              );
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
                          _signInWithGoogle();
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
                          _signInAnonymous();
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

  void _signInWithGoogle() async {
    _sendLoginEvent("Google");
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  void _signInAnonymous() async {
    _sendLoginEvent("Anonymous");
    await _auth.signInAnonymously();
  }

  _sendLoginEvent(String type) async {
    await _analytics.logEvent(
      name: 'click_login',
      parameters: <String, dynamic>{'value': type},
    );
  }

  _loadImage() {
    load("assets/images/background.jpg").then((image) {
      setState(() {
        this.image = image;
      });
    });
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

Future<ui.Image> load(String asset) async {
  ByteData data = await rootBundle.load(asset);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}
