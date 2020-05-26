import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:registry_helper_for_wu/resources/values/app_colors.dart';

import 'bottom_bar_nav.dart';
import 'resources/i18n/app_strings.dart';
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
            if (notification.metrics.pixels >= (150 + MediaQuery.of(context).padding.top)) {
                uiStore.isRegistryRowAtTop = true;
            } else if (notification.metrics.pixels < 150 + 300) {
              uiStore.isRegistryRowAtTop = false;
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
                  expandedHeight: 150,
                  floating: false,
                  pinned: false,
                  actions: <Widget>[
                    IconButton(icon: Icon(Icons.settings, color: AppColors.backgroundColorBottomBar,),),
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
