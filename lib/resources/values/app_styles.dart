import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

abstract class AppStyles {
  static final appThemeData = ThemeData(
    primarySwatch: AppColors.backgroundMaterialColor,
    fontFamily: 'Raleway',
  );

  // default font size = 14.0

  static const mediumText = TextStyle(
    fontSize: AppDimens.mediumSize,
    color: AppColors.lightTextColor,
  );

  static const largeText = TextStyle(
    fontSize: AppDimens.largeSize,
    color: AppColors.lightTextColor,
  );

  static const largeBoldText = TextStyle(
    fontSize: AppDimens.largeSize,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextColor,
  );

  static const titleText = TextStyle(
    fontSize: AppDimens.megaSize,
    fontWeight: FontWeight.bold,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(AppDimens.shadowOffset, AppDimens.shadowOffset),
        blurRadius: AppDimens.shadowBlurRadius,
        color: AppColors.shadowColor,
      ),
    ],
  );

  static const extraLargeBoldText = TextStyle(
    fontSize: AppDimens.megaSize,
    fontWeight: FontWeight.bold,
  );

  static const darkText = TextStyle(
    color: AppColors.darkTextColor,
  );

  static const darkBoldText = TextStyle(
    color: AppColors.darkTextColor,
    fontWeight: FontWeight.bold,
  );

  static const darkBoldUnderlinedText = TextStyle(
    color: AppColors.darkTextColor,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
    decorationThickness: 3,
  );

  static const darkContentText = TextStyle(
    fontSize: AppDimens.contentSize,
    color: AppColors.darkTextColor,
  );

  static const darkBoldContentText = TextStyle(
    fontSize: AppDimens.contentSize,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextColor,
  );

  static const lightContentText = TextStyle(
    fontSize: AppDimens.contentSize,
    color: AppColors.lightTextColor,
  );

  static const lightBoldContentText = TextStyle(
    fontSize: AppDimens.contentSize,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextColor,
  );

  static const largeLightContentText = TextStyle(
    fontSize: AppDimens.megaSize,
    color: AppColors.lightTextColor,
  );

  static const tutorialText = largeBoldText;
  static const quantityText = largeLightContentText;

  static const zeroInsets = EdgeInsets.all(0.0);
  static const miniInsets = EdgeInsets.all(AppDimens.miniSize);
  static const mediumInsets = EdgeInsets.all(AppDimens.mediumSize);
  static const largeInsets = EdgeInsets.all(AppDimens.largeSize);

  // CHARTS
  static const chartsHowToCatchInsets = EdgeInsets.fromLTRB(AppDimens.smallSize, 0, 14, 0);
  static const chartsPlacedInsets = EdgeInsets.fromLTRB(AppDimens.mediumSize, 0, AppDimens.mediumSize, 0);
  static const chartsSeparatorsInsets = EdgeInsets.symmetric(vertical: 0, horizontal: AppDimens.largeSize);
  static TextStyle chartsTitle(Color color) {
    return TextStyle(
      color: color,
      fontSize: AppDimens.contentSize,
    );
  }
  static const chartsInsets = EdgeInsets.only(top: 270);
  //

  // HELPER
  static final helperDropdownThemeData = ThemeData(
    canvasColor: AppColors.backgroundColor,
    fontFamily: 'Raleway',
  );
  static const helperAlmostCompleteInsets = EdgeInsets.only(bottom: AppDimens.miniSize);
  static const helperChallengesInsets = EdgeInsets.fromLTRB(AppDimens.gigaSize, 0, 0, 0);
  static const helperChapterInsets = EdgeInsets.symmetric(vertical: 0, horizontal: AppDimens.miniSize);
  static const helperDialogCardInsets = EdgeInsets.symmetric(horizontal: AppDimens.mediumSize);
  static const helperDialogPaddingInsets = EdgeInsets.fromLTRB(AppDimens.megaSize, AppDimens.miniSize, AppDimens.megaSize, AppDimens.mediumSize);
  static const helperDialogBodyInsets = EdgeInsets.fromLTRB(AppDimens.mediumSize, 0, 0, 0);
  static TextStyle helperDialogTitleText(Color color) {
    return TextStyle(
      color: color,
      fontSize: AppDimens.largeSize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle helperDialogBoldBodyText(Color color) {
    return TextStyle(
      color: color,
      fontSize: AppDimens.contentSize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle helperDialogBodyText(Color color) {
    return TextStyle(
      color: color,
      fontSize: AppDimens.contentSize,
    );
  }
  //

  // MY REGISTRY
  static const registryIndexInsets = EdgeInsets.only(right: AppDimens.microSize);
  //
}
