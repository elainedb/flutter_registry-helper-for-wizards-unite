import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../data/data.dart';
import '../../resources/i18n/app_strings.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/registry_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/fanalytics.dart';

Widget chapterCard(String chapterId, Color dark, Color light, int index, AutoScrollController controller, GlobalKey globalKey1, GlobalKey globalKey2, GlobalKey globalKey3, Function pushDialog) {
  final registryStore = GetIt.instance<RegistryStore>();
  Chapter chapter = getChapterWithId(registryStore.registry, chapterId);

  List<Widget> widgets = List();
  widgets.add(Text(
    "${chapter.id.i18n()}",
    style: AppStyles.lightContentText,
  ));
  widgets.addAll(getPagesIds(chapter).map((p) => pageCard(p, chapter, light, dark, globalKey1, globalKey2, globalKey3, pushDialog)));

  return AutoScrollTag(
    controller: controller,
    key: ValueKey(index),
    index: index,
    child: Card(
      color: dark,
      child: Column(
        children: widgets,
      ),
    ),
  );
}

Widget pageCard(String pageId, Chapter chapter, Color lightColor, Color darkColor, GlobalKey globalKey1, GlobalKey globalKey2, GlobalKey globalKey3, Function pushDialog) {
  final userDataStore = GetIt.instance<UserDataStore>();
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
        onPressed: () => pushDialog(dropdownValue, page, darkColor, lightColor),
      )
    ],
  );

  List<Widget> widgets = List();
  widgets.add(header);
  widgets.addAll(getFoundablesIds(page).map((f) => foundableRow(f, page, darkColor, globalKey2)));

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

Widget foundableRow(String foundableId, WUPage page, Color color, GlobalKey globalKey2) {
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();

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
            color: isPlaced ? AppColors.placedStar : AppColors.notPlacedStar,
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