import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';

abstract class MyRegistryTutorial {
  static List<TargetFocus> targets = List();

  static initTargets(GlobalKey globalKey1, GlobalKey globalKey2, GlobalKey globalKey3, GlobalKey globalKey4) {
    targets.add(
      TargetFocus(
        identify: "target1",
        keyTarget: globalKey1,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
              align: AlignContent.bottom,
              child: Text(
                "Click here to edit the fragment count for this page.",
                style: AppStyles.tutorialText,
                textAlign: TextAlign.right,
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
              "After successfully retrieving a foundable, click on this button to add a fragment.",
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
              "Set your current prestige level here.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "target4",
        keyTarget: globalKey4,
        shape: ShapeLightFocus.Circle,
        contents: [
          ContentTarget(
            align: AlignContent.left,
            child: Text(
              "\nQuickly access other families.",
              style: AppStyles.tutorialText,
              textAlign: TextAlign.end,
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
