import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';

abstract class ChartsTutorial {
  static List<TargetFocus> targets = List();

  static initTargets(GlobalKey globalKey1, GlobalKey globalKey2, GlobalKey globalKey3) {
    targets.add(
      TargetFocus(
        identify: "target1",
        keyTarget: globalKey1,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
              align: AlignContent.top,
              child: Text(
                "You can visualize your progress here. Click on a bar in order to see the foundable behind it.",
                style: AppStyles.tutorialText,
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target2",
        keyTarget: globalKey2,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Text(
              "Information about the threat level (color) and how to catch (icon) is shown here.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target3",
        keyTarget: globalKey3,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Text(
              "Here's the legend for the icons shown below the charts.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static showTutorial(BuildContext context) {
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: AppColors.tutorialColor,
      textSkip: "SKIP",
      paddingFocus: AppDimens.paddingFocus,
      opacityShadow: AppDimens.opacityShadow,
      finish: () {
        print("finish");
      },
      clickTarget: (target) {
        print(target);
      },
      clickSkip: () {
        print("skip");
      },
    )..show();
  }
}
