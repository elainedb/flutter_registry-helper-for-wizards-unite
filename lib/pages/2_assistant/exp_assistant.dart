import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'tutorial.dart';

class ExpAssistantPage extends StatefulWidget {
  final String _initialSortValue;
  ExpAssistantPage(this._initialSortValue);

  @override
  State<StatefulWidget> createState() => ExpAssistantPageState(_initialSortValue);
}

class ExpAssistantPageState extends State<ExpAssistantPage> {
  String _initialSortValue;
  ExpAssistantPageState(this._initialSortValue);

  String _dropdownValue = sortValues[0];

  GlobalKey globalKey1 = GlobalKey();
  GlobalKey globalKey2 = GlobalKey();
  bool _tutorialShown;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  void initState() {
    super.initState();
    AssistantTutorial.initTargets(globalKey1, globalKey2);
    _getTutorialInfoFromSharedPrefs();

    if (_initialSortValue.isNotEmpty) {
      _dropdownValue = _initialSortValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget._initialSortValue.isNotEmpty) {
      // fix for shortcut when page already displaying
      _dropdownValue = widget._initialSortValue;
      _initialSortValue = "";
    }

    if (userDataStore.isLoading) {
      return LoadingWidget();
    } else {
      return _generalHelper(userDataStore.data);
    }
  }

  Widget _generalHelper(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild(context));

    List<Widget> widgets = List();
    widgets.add(Padding(
      padding: AppStyles.miniInsets,
      child: Text(
        "missing_foundables_description".i18n(),
        style: AppStyles.lightContentText,
      ),
    ));
    widgets.add(Padding(
      padding: AppStyles.miniInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "sort_by".i18n(),
            style: AppStyles.lightContentText,
          ),
          Theme(
            data: AppStyles.helperDropdownThemeData,
            child: DropdownButton<String>(
              key: globalKey2,
              value: _dropdownValue,
              onChanged: (newValue) {
                analytics.sendAnalyticsEvents(_dropdownValue);
                setState(() {
                  _dropdownValue = newValue;
                });
              },
              items: sortValues.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.i18n(),
                    style: AppStyles.lightContentText,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ));

    Map<Widget, int> chapterRowsMap = Map();
    explorationChaptersForDisplay.asMap().forEach((index, chapterForDisplay) {
      var chapter = getChapterWithId(registryStore.registry, chapterForDisplay.id);
      var missingTraces = getMissingTracesForChapter(chapter, data);
      var value = index;

      if (_dropdownValue == "sort_low")
        value = missingTraces.low + missingTraces.medium;
      else if (_dropdownValue == "sort_high")
        value = missingTraces.high;
      else if (_dropdownValue == "sort_severe")
        value = missingTraces.severe;
      else if (_dropdownValue == "sort_emergency")
        value = missingTraces.emergency;
      else if (_dropdownValue == "sort_fortress") value = missingTraces.challenges;
      chapterRowsMap[_chapterRow(chapterForDisplay, chapter, missingTraces)] = value;
    });

    if (_dropdownValue != "sort_default") {
      var sortedValues = chapterRowsMap.values.toList()..sort();
      sortedValues.reversed.forEach((i) {
        var key = chapterRowsMap.keys.firstWhere((k) => chapterRowsMap[k] == i && !widgets.contains(k));
        widgets.add(key);
      });
    } else {
      chapterRowsMap.forEach((chapterRow, count) {
        widgets.add(chapterRow);
      });
    }

    return Observer(builder: (_) {
      return ListView(
        physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        children: widgets,
      );
    });
  }

  Widget _chapterRow(ChapterForDisplay chapterForDisplay, Chapter chapter, MissingTraces missingTraces) {
    var key;
    if (chapterForDisplay.id == "cmc") {
      key = globalKey1;
    }
    return GestureDetector(
      onTap: () => _pushDialog(chapterForDisplay, chapter),
      child: Card(
        key: key,
        color: chapterForDisplay.lightColor,
        child: Padding(
          padding: AppStyles.helperChapterInsets,
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.largeImageSize,
                child: Hero(
                  tag: chapterForDisplay.id,
                  child: Image.asset("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _missingWidget(AppColors.lowAltThreatColor, "${missingTraces.low + missingTraces.medium}", Icons.radio_button_unchecked),
                    _missingWidget(AppColors.highThreatColor, "${missingTraces.high}", Icons.brightness_1),
                    _missingWidget(AppColors.severeThreatColor, "${missingTraces.severe}", Icons.brightness_1),
                    _missingWidget(AppColors.emergencyThreatColor, "${missingTraces.emergency}", Icons.brightness_1),
                    _missingChallenges("${missingTraces.challenges}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missingWidget(Color color, String text, IconData iconData) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(
          iconData,
          color: color,
          size: AppDimens.missingWidgetSize,
        ),
        Text(
          text,
          style: AppStyles.darkContentText,
        ),
      ],
    );
  }

  Widget _missingChallenges(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.flash_on,
          size: AppDimens.mediumSize,
        ),
        Container(
            width: AppDimens.largeSize,
            child: Text(
              text,
              style: AppStyles.darkContentText,
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  _pushDialog(ChapterForDisplay chapterForDisplay, Chapter chapter) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (BuildContext context, _, __) {
        return Center(
          child: Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 5,
                margin: AppStyles.helperDialogCardInsets,
                color: chapterForDisplay.lightColor,
                child: Padding(
                  padding: AppStyles.helperDialogPaddingInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Center(
                          child: Text(
                        chapter.id.i18n(),
                        style: AppStyles.helperDialogTitleText(chapterForDisplay.darkColor),
                      )),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "osm_value".i18n(),
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          "${chapter.id}_osm".i18n(),
                          style: AppStyles.helperDialogBoldBodyText(chapterForDisplay.darkColor),
                        ),
                      ),
                      Container(
                        height: AppDimens.megaSize,
                      ),
                      Text(
                        "examples".i18n(),
                        style: AppStyles.helperDialogBodyText(chapterForDisplay.darkColor),
                      ),
                      Padding(
                        padding: AppStyles.helperDialogBodyInsets,
                        child: Text(
                          "${chapter.id}_examples".i18n(),
                          style: AppStyles.helperDialogBoldBodyText(chapterForDisplay.darkColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppDimens.negativeDialogMargin,
                child: Hero(
                  tag: chapterForDisplay.id,
                  child: Image(
                    image: AssetImage("assets/images/traces_transparent/${chapterForDisplay.id}.png"),
                    width: AppDimens.megaImageSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  executeAfterBuild(_) {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!_tutorialShown) {
        AssistantTutorial.showTutorial(context);
        setState(() {
          setTutorialShown();
        });
      }
    });
  }

  Future<void> setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorialShown = true;
    await prefs.setBool('tutorialHelper', true);
  }

  _getTutorialInfoFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tutorialRegistryShown = prefs.getBool('tutorialHelper') ?? false;
    setState(() {
      _tutorialShown = tutorialRegistryShown;
    });
  }
}

class MissingTraces {
  final int low;
  final int medium;
  final int high;
  final int severe;
  final int emergency;
  final int challenges;

  MissingTraces(this.low, this.medium, this.high, this.severe, this.emergency, this.challenges);
}
