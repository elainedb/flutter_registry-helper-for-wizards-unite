import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import '../../resources/i18n/app_strings.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/registry_store.dart';

List<Widget> getPagesWithOneOreTwoMissingWidgets(Map<String, dynamic> data, List<ChapterForDisplay> chaptersForDisplay) {
  final registryStore = GetIt.instance<RegistryStore>();
  List<Widget> widgets = List();
  widgets.add(Padding(
    padding: AppStyles.mediumInsets,
    child: Text(
      "focused_playing".i18n(),
      style: AppStyles.lightContentText,
      textAlign: TextAlign.center,
    ),
  ));
  chaptersForDisplay.forEach((chapterForDisplay) {
    var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
    List<AlmostCompletePage> almostCompletePages = getPagesWithOneOreTwoMissing(chapter, data);
    almostCompletePages.forEach((almostCompletePage) {
      widgets.add(_getAlmostCompletePageWidget(almostCompletePage, chapter.id));
    });
  });

  if (widgets.length == 1) {
    return null;
  }
  return widgets;
}

Widget _getAlmostCompletePageWidget(AlmostCompletePage almostCompletePage, String chapterId) {
  List<Widget> widgets = List();
  widgets.add(Padding(
    padding: AppStyles.helperAlmostCompleteInsets,
    child: Text(
      almostCompletePage.pageName,
      style: AppStyles.lightContentText,
    ),
  ));
  almostCompletePage.foundables.forEach((foundable) {
    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: AppDimens.mediumImageSize,
          child: Image.asset("assets/images/traces_transparent/$chapterId.png"),
        ),
        SizedBox(
          width: AppDimens.mediumImageSize,
          height: AppDimens.mediumImageSize,
          child: Image.asset("assets/images/foundables/${foundable.foundable.id}.png"),
        ),
        SizedBox(
          width: AppDimens.smallImageSize,
          child: getIconWithFoundable(foundable.foundable, AppDimens.smallImageSize),
        ),
        Text(
          "left".i18n().replaceFirst("arg1", "${foundable.remainingFragments}"),
          style: AppStyles.lightContentText,
        ),
      ],
    ));

    widgets.add(
      Text(
        foundable.foundable.name,
        style: AppStyles.lightBoldContentText,
      ),
    );

    if (foundable.foundable.howToCatch.contains(",") || foundable.foundable.howToCatch.contains("r1")) {
      widgets.add(
        Text(
          foundable.foundable.howToCatch.split(",").map((e) => e.i18n()).join("\n"),
          style: AppStyles.lightContentText,
        ),
      );
    }

    widgets.add(
      Padding(
        padding: AppStyles.mediumInsets,
        child: Container(
          color: AppColors.lightColor,
          height: AppDimens.picoSize,
        ),
      ),
    );
  });

  widgets.removeLast();

  return Card(
    color: Colors.transparent,
    child: Padding(
      padding: AppStyles.miniInsets,
      child: Column(
        children: widgets,
      ),
    ),
  );
}
