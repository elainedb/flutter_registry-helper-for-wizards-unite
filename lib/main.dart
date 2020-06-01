import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:registry_helper_for_wu/store/ui_store.dart';

import 'sliver.dart';
import 'resources/values/app_colors.dart';
import 'resources/values/app_styles.dart';
import 'signin.dart';
import 'store/authentication.dart';
import 'store/registry_store.dart';
import 'store/signin_image.dart';
import 'store/user_data_store.dart';
import 'resources/i18n/app_strings.dart';
import 'utils/fanalytics.dart';
import 'utils/globals.dart' as globals;

void main() {
  Crashlytics.instance.enableInDevMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.recordFlutterError(details);
  };

  //override the red screen of death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    Crashlytics.instance.recordFlutterError(details);
    return Scaffold(
      body: Padding(
        padding: AppStyles.miniInsets,
        child: Center(
          child: Text(
            "error".i18n(),
            style: AppStyles.largeText,
          ),
        ),
      ),
    );
  };

  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<Authentication>(Authentication());
  getIt.registerSingleton<SignInImage>(SignInImage());
  getIt.registerSingleton<RegistryStore>(RegistryStore());
  getIt.registerSingleton<UserDataStore>(UserDataStore());
  getIt.registerSingleton<FAnalytics>(FAnalytics());
  getIt.registerSingleton<UiStore>(UiStore());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      theme: AppStyles.appThemeData,
      home: MyHomePage(),
      navigatorObservers: <NavigatorObserver>[FAnalytics.observer],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'en'),
        const Locale.fromSubtags(languageCode: 'fr'),
        const Locale.fromSubtags(languageCode: 'pt'),
        const Locale.fromSubtags(languageCode: 'es'),
      ],
//      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  final authentication = GetIt.instance<Authentication>();
  final analytics = GetIt.instance<FAnalytics>();

  @override
  void initState() {
    super.initState();
    authentication.initAuthState();
  }

  @override
  Widget build(BuildContext context) {
    print("main build");

    Locale myLocale = Localizations.localeOf(context);
    print(myLocale.languageCode);
    globals.lang = myLocale.languageCode;

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Observer(builder: (_) {
          return authentication.authState ? SliverWidget() : SignInWidget();
        });
      }),
      backgroundColor: AppColors.backgroundMaterialColor,
    );
  }
}
