import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'challenges.dart';
import 'exploration.dart';
import 'pages/settings.dart';
import 'resources/i18n/app_strings.dart';
import 'resources/values/app_colors.dart';
import 'resources/values/app_dimens.dart';
import 'resources/values/app_styles.dart';
import 'store/ui_store.dart';

class SliverWidget extends StatefulWidget {
  SliverWidget();

  @override
  State<StatefulWidget> createState() => SliverWidgetState();
}

class SliverWidgetState extends State<SliverWidget> with SingleTickerProviderStateMixin {
  SliverWidgetState();

  TabController _tabController;
  ScrollController _scrollController;
  final uiStore = GetIt.instance<UiStore>();
  bool isLeftSelected = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabSelection);

    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return _tabControllerWidget();
  }

  Widget _tabControllerWidget() {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            if(notification.dragDetails == null && uiStore.isMainChildAtTop) {
              _scrollController.jumpTo(AppDimens.sliverAppBarHeight);
              uiStore.isMainChildAtTop = false;
            }
          } else {
            Future.delayed(Duration(milliseconds: 300), () {
              if (notification.metrics.pixels >= (MediaQuery.of(context).padding.top + AppDimens.sliverAppBarHeight)) {
                uiStore.isMainChildAtTop = true;
              } else if (notification.metrics.pixels < AppDimens.sliverAppBarHeight + 300) {
                uiStore.isMainChildAtTop = false;
              }
            });
          }
          return;
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              /*SliverToBoxAdapter(
                child: Container(
                  color: AppColors.placedStar,
                    height: 200,
                ),
              ),*/
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
//                  backgroundColor: Colors.transparent,
                  backgroundColor: AppColors.backgroundColorBottomBar,
                  /*title: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      height: 50,
                      color: AppColors.backgroundColorBottomBar,
                    ),
                  ),*/
                  title: Text("app_name_short".i18n(), style: AppStyles.darkBoldText,),
                  centerTitle: true,
                  expandedHeight: AppDimens.sliverAppBarHeight,
                  floating: false,
                  pinned: false,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: AppColors.backgroundColor,
                      ),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage())),
                    ),
                  ],
                  bottom: TabBar(
                    labelPadding: EdgeInsets.zero,
                    controller: _tabController,
                    labelColor: AppColors.backgroundColor,
                    indicatorColor: AppColors.backgroundColor,
                    unselectedLabelColor: AppColors.backgroundColor,
                    indicatorWeight: 0.0001,
                    tabs: [
                      Container(
                        height: AppDimens.sliverTabBarHeight,
                        width: MediaQuery.of(context).size.width / 2,
                        color: AppColors.backgroundColor,
                        child: ClipPath(
                          clipper: CurvedBottomClipper(true),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            color: AppColors.backgroundColorBottomBar,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: AppStyles.largeInsets,
                                    child: Text("exploration".i18n(), style: isLeftSelected ? AppStyles.darkBoldUnderlinedText : AppStyles.darkText,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: AppDimens.sliverTabBarHeight,
                        width: MediaQuery.of(context).size.width / 2,
                        color: AppColors.backgroundColor,
                        child: ClipPath(
                          clipper: CurvedBottomClipper(false),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            color: AppColors.backgroundColorBottomBar,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              color: AppColors.backgroundColorBottomBar,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: AppStyles.largeInsets,
                                      child: Text("challenges".i18n(), style: isLeftSelected ? AppStyles.darkText : AppStyles.darkBoldUnderlinedText,),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              ExplorationWidget(),
              ChallengesWidget(),
            ].toList(),
          ),
        ),
      ),
    );
  }

  _handleTabSelection() {
    setState(() {
      String pageName = "";
      switch (_tabController.index) {
        case 0:
          setState(() {
            isLeftSelected = true;
          });
          pageName = "HelperPage_MissingFoundables";
          break;
        case 1:
          setState(() {
            isLeftSelected = false;
          });
          pageName = "HelperPage_Insights";
          break;
      }

//      analytics.sendTab(pageName);
    });
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  final bool isLeft;

  CurvedBottomClipper(bool this.isLeft);

  @override
  Path getClip(Size size) {
    final roundingHeight = size.height * 1.3;

    // this is top part of path, rectangle without any rounding
    final filledRectangle = Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    // this is rectangle that will be used to draw arc
    // arc is drawn from center of this rectangle, so it's height has to be twice roundingHeight
    Rect roundingRectangle = Rect.fromLTRB(-size.width, size.height - roundingHeight * 2, size.width + 5, size.height);
    if (isLeft) {
      roundingRectangle = Rect.fromLTRB(-5, size.height - roundingHeight * 2, size.width * 2, size.height);
    }

    final path = Path();
    path.addRect(filledRectangle);

    // so as I wrote before: arc is drawn from center of roundingRectangle
    // 2nd and 3rd arguments are angles from center to arc start and end points
    // 4th argument is set to true to move path to rectangle center, so we don't have to move it manually
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
