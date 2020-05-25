import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';
import '../resources/values/app_colors.dart';
import '../resources/values/app_dimens.dart';
import '../resources/values/app_styles.dart';
import '../store/authentication.dart';
import '../store/registry_store.dart';
import '../store/user_data_store.dart';
import '../resources/i18n/app_strings.dart';
import '../utils/fanalytics.dart';
import '../widgets/page_edit_dialog.dart';
import '../widgets/loading.dart';
import 'tutorial/my_registry_tutorial.dart';

class MyRegistryPage extends StatefulWidget {
  MyRegistryPage();

  @override
  State<StatefulWidget> createState() => MyRegistryPageState();
}

class MyRegistryPageState extends State<MyRegistryPage> {
  MyRegistryPageState();

//  AutoScrollController controller;

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  GlobalKey globalKey3 = GlobalKey();
  GlobalKey globalKey4 = GlobalKey();
  bool _tutorialShown;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();

  @override
  void initState() {
    super.initState();
    MyRegistryTutorial.initTargets(globalKey1, globalKey2, globalKey3, globalKey4);
    _getTutorialInfoFromSharedPrefs();

//    controller = AutoScrollController(
//      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
//      axis: Axis.vertical,
//    );
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
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
//            controller: controller,
            slivers: <Widget>[
              SliverOverlapInjector(
                // This is the flip side of the SliverOverlapAbsorber above.
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(child: chapterCard("cmc", AppColors.cmcDark, AppColors.cmcLight, 0)),
              SliverToBoxAdapter(child: chapterCard("da", AppColors.daDark, AppColors.daLight, 1)),
              SliverToBoxAdapter(child: chapterCard("hs", AppColors.hsDark, AppColors.hsLight, 2)),
              SliverToBoxAdapter(child: chapterCard("loh", AppColors.lohDark, AppColors.lohLight, 3)),
              SliverToBoxAdapter(child: chapterCard("mom", AppColors.momDark, AppColors.momLight, 4)),
              SliverToBoxAdapter(child: chapterCard("m", AppColors.mDark, AppColors.mLight, 5)),
              SliverToBoxAdapter(child: chapterCard("mgs", AppColors.mgsDark, AppColors.mgsLight, 6)),
              SliverToBoxAdapter(child: chapterCard("mar", AppColors.maDark, AppColors.maLight, 7)),
              SliverToBoxAdapter(child: chapterCard("www", AppColors.wwwDark, AppColors.wwwLight, 8)),
              SliverToBoxAdapter(child: chapterCard("o", AppColors.oDark, AppColors.oLight, 9)),
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
                GestureDetector(child: Image.asset("assets/images/icons/cmc.png"), onTap: () => _scrollToIndex(0)),
                GestureDetector(child: Image.asset("assets/images/icons/da.png"), onTap: () => _scrollToIndex(1)),
                GestureDetector(child: Image.asset("assets/images/icons/hs.png"), onTap: () => _scrollToIndex(2)),
                GestureDetector(child: Image.asset("assets/images/icons/loh.png"), onTap: () => _scrollToIndex(3)),
                GestureDetector(key: globalKey4, child: Image.asset("assets/images/icons/mom.png"), onTap: () => _scrollToIndex(4)),
                GestureDetector(child: Image.asset("assets/images/icons/m.png"), onTap: () => _scrollToIndex(5)),
                GestureDetector(child: Image.asset("assets/images/icons/mgs.png"), onTap: () => _scrollToIndex(6)),
                GestureDetector(child: Image.asset("assets/images/icons/mar.png"), onTap: () => _scrollToIndex(7)),
                GestureDetector(child: Image.asset("assets/images/icons/www.png"), onTap: () => _scrollToIndex(8)),
                GestureDetector(child: Image.asset("assets/images/icons/o.png"), onTap: () => _scrollToIndex(9)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget chapterCard(String chapterId, Color dark, Color light, int index) {
    Chapter chapter = getChapterWithId(registryStore.registry, chapterId);

    List<Widget> widgets = List();
    widgets.add(Text(
      "${chapter.id.i18n()}",
      style: AppStyles.lightContentText,
    ));
    widgets.addAll(getPagesIds(chapter).map((p) => pageCard(p, chapter, light, dark)));

    return /*AutoScrollTag(
      controller: controller,
      key: ValueKey(index),
      index: index,
      child: */Card(
        color: dark,
        child: Column(
          children: widgets,
        ),
      )/*,
    )*/;
  }

  Widget pageCard(String pageId, Chapter chapter, Color lightColor, Color darkColor) {
    WUPage page = getPageWithId(chapter, pageId);
    String dropdownValue = getPrestigeLevelWithPageId(pageId, userDataStore.data);
    var key1;
    var key3;
    if (pageId == "hh") {
      key1 = globalKey1;
      key3 = globalKey3;
    }

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
            child: Text(
          "${page.id.i18n()}",
          style: AppStyles.darkBoldContentText,
          textAlign: TextAlign.center,
        )),
        DropdownButton<String>(
          key: key3,
          value: dropdownValue,
          onChanged: (newValue) => userDataStore.setPrestigeLevel(page, newValue),
          items: prestigeValues.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.i18n(),
                style: AppStyles.darkContentText,
              ),
            );
          }).toList(),
        ),
        IconButton(
          key: key1,
          icon: Icon(
            Icons.edit,
            color: AppColors.darkColor,
          ),
          onPressed: () => _pushDialog(dropdownValue, page, darkColor, lightColor),
        )
      ],
    );

    List<Widget> widgets = List();
    widgets.add(header);
    widgets.addAll(getFoundablesIds(page).map((f) => foundableRow(f, page, darkColor)));

    return Card(
      color: lightColor,
      child: Padding(
        padding: AppStyles.miniInsets,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  Widget foundableRow(String foundableId, WUPage page, Color color) {
    Foundable foundable = getFoundableWithId(page, foundableId);
    int currentCount = userDataStore.data[foundableId]['count'];
    int currentLevel = userDataStore.data[foundableId]['level'];
    bool isPlaced = userDataStore.data[foundableId]['placed'];
    var intRequirement = getRequirementWithLevel(foundable, currentLevel);

    List<Widget> widgets = List();

    var key2;
    if (foundableId == "hh_1") {
      key2 = globalKey2;
    }

    widgets.addAll([
      GestureDetector(
        onTap: () {
          userDataStore.submitPlaced(foundable, !isPlaced);
          analytics.sendPlacedEvent();
        },
        child: Stack(
          children: [
            Container(
              width: AppDimens.mediumImageSize,
              height: AppDimens.mediumImageSize,
              child: Image.asset("assets/images/foundables/$foundableId.png"),
            ),
            Icon(
              Icons.stars,
              color: isPlaced ? Colors.green : Colors.grey,
              size: AppDimens.miniImageSize,
            ),
          ],
        ),
      ),
      Expanded(
          child: Text(
        foundable.id.i18n(),
        style: AppStyles.darkContentText,
      )),
    ]);

    if (currentCount < intRequirement) {
      widgets.addAll([
        Container(
          width: AppDimens.gigaSize,
          child: RaisedButton(
            key: key2,
            color: AppColors.backgroundColor,
            padding: AppStyles.zeroInsets,
            child: Text(
              "+",
              style: AppStyles.quantityText,
            ),
            onPressed: () {
              analytics.sendPlusEvent();
              userDataStore.submitNewValue(foundable, (currentCount + 1).toString());
            },
          ),
        ),
      ]);

      widgets.add(Container(
        alignment: Alignment.center,
        width: AppDimens.registryCounterWidth,
        child: Card(
          child: Padding(
            padding: AppStyles.miniInsets,
            child: Text(
              "$currentCount / $intRequirement",
              style: AppStyles.darkContentText,
            ),
          ),
          color: Colors.transparent,
          elevation: 0,
        ),
      ));
    } else {
      if (currentCount > intRequirement) {
        // needed after 2.13 game update
        currentCount = intRequirement;
        userDataStore.submitNewValue(foundable, currentCount.toString());
      }
      widgets.add(Container(
        alignment: Alignment.center,
        width: AppDimens.registryCounterWidth,
        child: Card(
          child: Padding(
            padding: AppStyles.miniInsets,
            child: Text(
              "$currentCount / $intRequirement",
              style: AppStyles.lightContentText,
            ),
          ),
          color: color,
        ),
      ));
    }

    return Row(
      children: widgets,
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
//    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
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
