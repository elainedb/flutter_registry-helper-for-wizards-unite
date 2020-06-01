import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';
import 'page_edit_dialog.dart';
import 'registry_widgets.dart';
import 'tutorial.dart';

class ExpMyRegistryPage extends StatefulWidget {
  ExpMyRegistryPage();

  @override
  State<StatefulWidget> createState() => ExpMyRegistryPageState();
}

class ExpMyRegistryPageState extends State<ExpMyRegistryPage> {
  ExpMyRegistryPageState();

  AutoScrollController controller;

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  GlobalKey globalKey4 = GlobalKey();
  bool _tutorialShown;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  void initState() {
    super.initState();
    MyRegistryTutorial.initTargets(globalKey1, globalKey2, globalKey3, globalKey4);
    _getTutorialInfoFromSharedPrefs();

    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (userDataStore.isLoading) {
        return LoadingWidget();
      } else {
        return registryWidget();
      }
    });
  }

  Widget registryWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));

    return Row(
      children: <Widget>[
        Expanded(
          child: ListView(
            physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: controller,
            children: <Widget>[
              chapterCard("cmc", AppColors.cmcDark, AppColors.cmcLight, 0, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("da", AppColors.daDark, AppColors.daLight, 1, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("hs", AppColors.hsDark, AppColors.hsLight, 2, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("loh", AppColors.lohDark, AppColors.lohLight, 3, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("mom", AppColors.momDark, AppColors.momLight, 4, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("m", AppColors.mDark, AppColors.mLight, 5, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("mgs", AppColors.mgsDark, AppColors.mgsLight, 6, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("mar", AppColors.maDark, AppColors.maLight, 7, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("www", AppColors.wwwDark, AppColors.wwwLight, 8, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
              chapterCard("o", AppColors.oDark, AppColors.oLight, 9, controller, globalKey1, globalKey2, globalKey3, _pushDialog),
            ],
          ),
        ),
        Padding(
          padding: AppStyles.registryIndexInsets,
          child: Container(
            width: AppDimens.registryIndexWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/cmc.png"), onTap: () => _scrollToIndex(0))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/da.png"), onTap: () => _scrollToIndex(1))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/hs.png"), onTap: () => _scrollToIndex(2))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/loh.png"), onTap: () => _scrollToIndex(3))),
                Expanded(child: GestureDetector(key: globalKey4, child: Image.asset("assets/images/icons/mom.png"), onTap: () => _scrollToIndex(4))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/m.png"), onTap: () => _scrollToIndex(5))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/mgs.png"), onTap: () => _scrollToIndex(6))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/mar.png"), onTap: () => _scrollToIndex(7))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/www.png"), onTap: () => _scrollToIndex(8))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/o.png"), onTap: () => _scrollToIndex(9))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _pushDialog(String dropdownValue, WUPage page, Color darkColor, Color lightColor) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return PageEditDialog(page, dropdownValue, darkColor, lightColor);
        }));
  }

  Future _scrollToIndex(int index) async {
    analytics.sendScrollToEvent(index);
    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        MyRegistryTutorial.showTutorial(context);
        setTutorialShown();
      }
    });
  }

  Future<void> setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorialShown = true;
    await prefs.setBool('tutorialRegistry', true);
  }

  _getTutorialInfoFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tutorialRegistryShown = prefs.getBool('tutorialRegistry') ?? false;
    setState(() {
      _tutorialShown = tutorialRegistryShown;
    });
  }
}
