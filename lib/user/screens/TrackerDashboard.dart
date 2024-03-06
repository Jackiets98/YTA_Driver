import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../user/screens/WalletScreen.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/components/UserCitySelectScreen.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/models.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Constants.dart';
import '../../user/components/FilterOrderComponent.dart';
import '../../user/fragment/AccountFragment.dart';
import '../../user/fragment/OrderFragment.dart';

import 'package:nb_utils/nb_utils.dart';

import '../fragment/ReportFragment.dart';

class TrackerDashboard extends StatefulWidget {
  static String tag = '/TrackerDashboard';

  @override
  TrackerDashboardState createState() => TrackerDashboardState();
}

class TrackerDashboardState extends State<TrackerDashboard> {
  List<BottomNavigationBarItemModel> bottomNavBarItems = [];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bottomNavBarItems.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: language.order));
    bottomNavBarItems.add(BottomNavigationBarItemModel(icon: Icons.person, title: language.account));
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
  }

  getOrderListApiCall() async {
    // appStore.setLoading(true);
    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String getTitle() {
    String title = language.myOrders;
    if (currentIndex == 0) {
      title = language.order;
    } else if (currentIndex == 1) {
      title = language.account;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('${getTitle()}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Align(alignment: AlignmentDirectional.center, child: Icon(Icons.person_outline)),
                Observer(builder: (context) {
                  return Positioned(
                    right: 2,
                    top: 8,
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: appStore.allUnreadCount > 99 ? 8 : 12, color: Colors.white)),
                    ),
                  ).visible(appStore.allUnreadCount != 0);
                }),
              ],
            ).withWidth(40).onTap(() {
              // AccountFragment().launch(context);
              NotificationScreen().launch(context);
            }).visible(currentIndex == 0),
          ),
        ],
      ),
      body: BodyCornerWidget(
        child: [
          AccountFragment(),
          OrderFragment(),
          ReportFragment(),
        ][currentIndex],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: context.cardColor,
        icons: [Icons.home, Icons.pin_drop, Icons.document_scanner_outlined, Icons.fire_truck_sharp],
        activeIndex: currentIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.defaultEdge,
        activeColor: colorPrimary,
        inactiveColor: Colors.grey,
        leftCornerRadius: 30,
        rightCornerRadius: 30,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
