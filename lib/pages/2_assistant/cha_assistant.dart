import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../resources/i18n/app_strings.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';

class ChaAssistantPage extends StatefulWidget {
  ChaAssistantPage();

  @override
  State<StatefulWidget> createState() => ChaAssistantPageState();
}

class ChaAssistantPageState extends State<ChaAssistantPage> {

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  Widget build(BuildContext context) {
    if (userDataStore.isLoading) {
      return LoadingWidget();
    } else {
      return _generalHelper(userDataStore.data);
    }
  }

  _generalHelper(Map<String, dynamic> data) {

    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        children: [
          _chapterCard("bo", AppColors.lohDark, AppColors.lohLight),
          _chapterCard("jp", AppColors.lohDark, AppColors.lohLight),
          _chapterCard("md", AppColors.lohDark, AppColors.lohLight),
          _chapterCard("sww", AppColors.lohDark, AppColors.lohLight),
          _chapterCard("wda", AppColors.lohDark, AppColors.lohLight),
        ],
      );
    });
  }

  Widget _chapterCard(String chapterId, Color dark, Color light) {
    Chapter chapter = getChapterWithId(registryStore.registry, chapterId);

    List<Widget> widgets = List();
    widgets.addAll(getPagesIds(chapter).map((p) => _pageCard(p, chapter, light, dark)));

    return Column(
      children: widgets,
    );
  }

  Widget _pageCard(String pageId, Chapter chapter, Color lightColor, Color darkColor) {
    WUPage page = getPageWithId(chapter, pageId);

    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
            child: Text(
              "${page.id.i18n()}",
              style: AppStyles.lightBoldContentText,
              textAlign: TextAlign.center,
            )),
      ],
    );

    List<Widget> widgets = List();
    widgets.add(header);
    widgets.addAll(getFoundablesIds(page).map((f) => _foundableRow(f, page, lightColor)));

    return Card(
      color: darkColor,
      child: Padding(
        padding: AppStyles.miniInsets,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  Widget _foundableRow(String foundableId, WUPage page, Color color) {
    Foundable foundable = getFoundableWithId(page, foundableId);
    int currentCount = userDataStore.data[foundableId]['count'];
    int currentLevel = userDataStore.data[foundableId]['level'];
    bool isPlaced = userDataStore.data[foundableId]['placed'];
    var intRequirement = getRequirementWithLevel(foundable, currentLevel);

    List<Widget> infoWidgets = List();

    infoWidgets.addAll([
      Stack(
        children: [
          Container(
            width: AppDimens.mediumImageSize,
            height: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/foundables/$foundableId.png"),
          ),
          Icon(
            Icons.stars,
            color: isPlaced ? AppColors.placedStar : AppColors.notPlacedStar,
            size: AppDimens.miniImageSize,
          ),
        ],
      ),
      Expanded(
          child: Text(
            foundable.id.i18n(),
            style: AppStyles.darkContentText,
          )),
    ]);

    infoWidgets.add(Container(
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

    Row infoRow = Row(
      children: infoWidgets,
    );

    Text chambersWidget = Text(
        foundable.howToCatch.split(",").map((e) => e.i18n()).join("\n"),
        style: AppStyles.darkBoldText,);

    return Card(
      color: color,
      child: Column(
        children: <Widget>[
          infoRow,
          chambersWidget,
        ],
      ),
    );
  }

}