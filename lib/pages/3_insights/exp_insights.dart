import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:registry_helper_for_wu/data/data.dart';
import 'package:registry_helper_for_wu/resources/values/app_colors.dart';
import 'package:registry_helper_for_wu/resources/values/app_dimens.dart';
import 'package:registry_helper_for_wu/resources/values/app_styles.dart';
import 'package:registry_helper_for_wu/store/authentication.dart';
import 'package:registry_helper_for_wu/store/registry_store.dart';
import 'package:registry_helper_for_wu/store/ui_store.dart';
import 'package:registry_helper_for_wu/store/user_data_store.dart';
import 'package:registry_helper_for_wu/utils/fanalytics.dart';
import 'package:registry_helper_for_wu/widgets/loading.dart';
import '../../resources/i18n/app_strings.dart';

class ExpInsightsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ExpInsightsPageState();
}

class ExpInsightsPageState extends State<ExpInsightsPage> {

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
      return _insights(userDataStore.data);
    }
  }

  Widget _insights(Map<String, dynamic> data) {
    List<Widget> widgets = List();

    if (_getNoClickWidgets(data) != null) {
      widgets.addAll(_getNoClickWidgets(data));
    }

    if (_getPagesWithOneOreTwoMissingWidgets(data) != null) {
      widgets.addAll(_getPagesWithOneOreTwoMissingWidgets(data));
    }

    if (_getPagesWithOneOreTwoMissingWidgets(data) == null && _getNoClickWidgets(data) == null) {
      return Text(
        "No insights for now!",
        style: AppStyles.lightContentText,
      );
    }

    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: widgets,
      );
    });
  }

  List<Widget> _getPagesWithOneOreTwoMissingWidgets(Map<String, dynamic> data) {
    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.mediumInsets,
      child: Text(
        "focused_playing".i18n(),
        style: AppStyles.lightContentText,
        textAlign: TextAlign.center,
      ),
    ));
    explorationChaptersForDisplay.forEach((chapterForDisplay) {
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
    });
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

  List<Widget> _getNoClickWidgets(Map<String, dynamic> data) {
    List<ZeroTracesLeft> zeroTracesLeftList = List();
    explorationChaptersForDisplay.forEach((chapterForDisplay) {
      var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, data);
      if (missingTraces.low + missingTraces.medium == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "low/medium"));
      }
      if (missingTraces.high == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "high"));
      }
      if (missingTraces.severe == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "severe"));
      }
      if (missingTraces.emergency == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "emergency"));
      }
      if (missingTraces.challenges == 0) {
        zeroTracesLeftList.add(ZeroTracesLeft(chapter.id, "challenges"));
      }
    });

    List<Widget> gridViewWidgets = List();
    zeroTracesLeftList.forEach((zero) {
      gridViewWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _getZeroWidget(zero),
        ],
      ));
    });

    List<Widget> widgets = List();
    if (gridViewWidgets.length > 0) {
      widgets.add(Padding(
        padding: AppStyles.miniInsets,
        child: Text(
          "no_click_zone".i18n(),
          style: AppStyles.lightContentText,
          textAlign: TextAlign.center,
        ),
      ));
      widgets.add(IgnorePointer(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          children: gridViewWidgets,
        ),
      ));
    }

    return widgets;
  }

  Widget _getZeroWidget(ZeroTracesLeft zeroTracesLeft) {
    Color color = Colors.transparent;
    switch (zeroTracesLeft.type) {
      case "high":
        color = AppColors.highThreatColor;
        break;
      case "severe":
        color = AppColors.severeThreatColor;
        break;
      case "emergency":
        color = AppColors.emergencyThreatColor;
        break;
    }

    if (zeroTracesLeft.type == "challenges") {
      return Container(
        width: AppDimens.largeImageSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: AppDimens.mediumImageSize,
              child: Image.asset("assets/images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
            ),
            Padding(
              padding: AppStyles.helperChallengesInsets,
              child: Icon(
                Icons.flash_on,
                color: Colors.white,
                size: AppDimens.smallImageSize,
              ),
            )
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.brightness_1,
            color: color,
            size: AppDimens.largeImageSize,
          ),
          Container(
            width: AppDimens.mediumImageSize,
            child: Image.asset("assets/images/traces_transparent/${zeroTracesLeft.chapterId}.png"),
          ),
        ],
      );
    }
  }

}

class ZeroTracesLeft {
  final String chapterId;
  final String type;

  ZeroTracesLeft(this.chapterId, this.type);
}