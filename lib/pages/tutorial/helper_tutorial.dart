import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';

abstract class HelperTutorial {
  static List<TargetFocus> targets = List();

  static initTargets(GlobalKey globalKey1, GlobalKey globalKey2, GlobalKey globalKey3) {
    targets.add(
      TargetFocus(
        identify: "target1",
        keyTarget: globalKey1,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
              align: AlignContent.bottom,
              child: Text(
                "Here you can find how many fragments are missing for each threat level. Information about where you can find nests for the family can be consulted by clicking here.",
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
              "You can sort this list by Threat Level or Fortress Rewards.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.right,
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
              "You can find personalized insights here.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.right,
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
