import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'bottom_bar_nav.dart';
import 'resources/values/app_colors.dart';
import 'resources/values/app_styles.dart';
import 'signin.dart';
import 'store/authentication.dart';
import 'store/registry_store.dart';
import 'utils/fanalytics.dart';
import 'store/signin_image.dart';
import 'widgets/loading.dart';

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
        child: const Center(
          child: Text(
            'An unexpected error occurred.',
            style: AppStyles.largeText,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundMaterialColor,
    );
  };

  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<Authentication>(Authentication());
  getIt.registerSingleton<SignInImage>(SignInImage());
  getIt.registerSingleton<RegistryStore>(RegistryStore());

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
      title: '',
      theme: AppStyles.appThemeData,
      home: MyHomePage(title: ''),
      navigatorObservers: <NavigatorObserver>[FAnalytics.observer],
//      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();

  @override
  void initState() {
    super.initState();

    authentication.initAuthState();

    if (authentication.authState) {
      authentication.sendUserId();
      registryStore.initRegistryDataFromJson();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("main build");

    return Scaffold(
      body: Builder(
          builder: (BuildContext context) {
      if(registryStore.isLoading) {
        return LoadingWidget();
      }

      return Observer(builder: (_) {
        return authentication.authState ? BottomBarNavWidget() : SignInWidget();
      });
    }), backgroundColor: AppColors.backgroundMaterialColor,);
  }

}
