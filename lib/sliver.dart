import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'bottom_bar_nav.dart';
import 'pages/settings.dart';
import 'resources/i18n/app_strings.dart';
import 'resources/values/app_colors.dart';
import 'resources/values/app_dimens.dart';
import 'store/ui_store.dart';

class SliverWidget extends StatefulWidget {
  SliverWidget();

  @override
  State<StatefulWidget> createState() => SliverWidgetState();
}

class SliverWidgetState extends State<SliverWidget> with SingleTickerProviderStateMixin {
  SliverWidgetState();

  TabController _controller;
  final uiStore = GetIt.instance<UiStore>();

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: 2);
    _controller.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    return _tabController();
  }

  Widget _tabController() {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          Future.delayed(Duration(milliseconds: 300), () {
            if (notification.metrics.pixels >= (MediaQuery.of(context).padding.top + AppDimens.sliverAppBarHeight)) {
              uiStore.isMainChildAtTop = true;
            } else if (notification.metrics.pixels < AppDimens.sliverAppBarHeight + 300) {
              uiStore.isMainChildAtTop = false;
            }
          });
          return;
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  expandedHeight: AppDimens.sliverAppBarHeight,
                  floating: false,
                  pinned: false,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: AppColors.backgroundColorBottomBar,
                      ),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage())),
                    ),
                  ],
                  bottom: TabBar(
                    controller: _controller,
                    labelColor: Colors.amber,
                    indicatorColor: Colors.amber,
                    tabs: [
                      Tab(text: "missing_foundables_title".i18n()),
                      Tab(text: "insights".i18n()),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _controller,
            children: [
              BottomBarNavWidget(),
              BottomBarNavWidget(),
            ].toList(),
          ),
        ),
      ),
    );
  }

  _handleTabSelection() {
    setState(() {
      String pageName = "";
      switch (_controller.index) {
        case 0:
          pageName = "HelperPage_MissingFoundables";
          break;
        case 1:
          pageName = "HelperPage_Insights";
          break;
      }

//      analytics.sendTab(pageName);
    });
  }
}
