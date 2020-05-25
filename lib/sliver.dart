import 'package:flutter/material.dart';

import 'bottom_bar_nav.dart';
import 'resources/i18n/app_strings.dart';
import 'resources/values/app_colors.dart';

class SliverWidget extends StatefulWidget {
  SliverWidget();

  @override
  State<StatefulWidget> createState() => SliverWidgetState();
}

class SliverWidgetState extends State<SliverWidget> with SingleTickerProviderStateMixin {
  SliverWidgetState();

  TabController _controller;

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
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 150,
                floating: false,
                pinned: false,
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
//          controller: _controller,
          children: [
            Builder(builder: (BuildContext context) {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                key: PageStorageKey<String>("missing_foundables_title".i18n()),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(height: 600, child: BottomBarNavWidget()),
                    ),
                  ),
                ],
              );
            }),
            Builder(builder: (BuildContext context) {
              return CustomScrollView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                key: PageStorageKey<String>("missing_foundables_title".i18n()),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        BottomBarNavWidget(),
                      ],
                    ),
                  )
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Widget> getTabBar() {
    return [
      SizedBox(
        height: 500,
        child: TabBarView(
          controller: _controller,
          children: [
            BottomBarNavWidget(),
            BottomBarNavWidget(),
          ],
        ),
      )
    ];
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
