import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../data/data.dart';
import '../../resources/values/app_colors.dart';
import '../../resources/values/app_dimens.dart';
import '../../resources/values/app_styles.dart';
import '../../store/authentication.dart';
import '../../store/registry_store.dart';
import '../../store/ui_store.dart';
import '../../store/user_data_store.dart';
import '../../utils/fanalytics.dart';
import '../../widgets/loading.dart';
import 'page_edit_dialog.dart';
import 'registry_widgets.dart';

class ChaMyRegistryPage extends StatefulWidget {
  ChaMyRegistryPage();

  @override
  State<StatefulWidget> createState() => ChaMyRegistryPageState();
}

class ChaMyRegistryPageState extends State<ChaMyRegistryPage> {
  ChaMyRegistryPageState();

  AutoScrollController controller;

  final authentication = GetIt.instance<Authentication>();
  final registryStore = GetIt.instance<RegistryStore>();
  final userDataStore = GetIt.instance<UserDataStore>();
  final analytics = GetIt.instance<FAnalytics>();
  final uiStore = GetIt.instance<UiStore>();

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical
    );
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
    return Row(
      children: <Widget>[
        Expanded(
          child: ListView(
            physics: uiStore.isMainChildAtTop ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: controller,
            children: <Widget>[
              chapterCard("bo", AppColors.lohDark, AppColors.lohLight, 0, controller, null, null, null, _pushDialog),
              chapterCard("jp", AppColors.lohDark, AppColors.lohLight, 1, controller, null, null, null, _pushDialog),
              chapterCard("md", AppColors.lohDark, AppColors.lohLight, 2, controller, null, null, null, _pushDialog),
              chapterCard("sww", AppColors.lohDark, AppColors.lohLight, 3, controller, null, null, null, _pushDialog),
              chapterCard("wda", AppColors.lohDark, AppColors.lohLight, 4, controller, null, null, null, _pushDialog),
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
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/bo.png"), onTap: () => _scrollToIndex(0))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/jp.png"), onTap: () => _scrollToIndex(1))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/md.png"), onTap: () => _scrollToIndex(2))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/sww.png"), onTap: () => _scrollToIndex(3))),
                Expanded(child: GestureDetector(child: Image.asset("assets/images/icons/wda.png"), onTap: () => _scrollToIndex(4))),
              ],
            ),
          ),
        ),
      ],
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
    await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin, duration: Duration(seconds: 1));
  }
}