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
import '../../user/screens/CreateOrderScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<BottomNavigationBarItemModel> bottomNavBarItems = [];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bottomNavBarItems.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: language.myOrders));
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
      title = language.myOrders;
    } else if (currentIndex == 1) {
      title = language.account;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('${getTitle()}'),
        actions: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              8.width,
              Text(CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate(), style: primaryTextStyle(color: white)),
            ],
          ).onTap(() {
            UserCitySelectScreen(
                isBack: true,
                onUpdate: () {
                  setState(() {});
                }).launch(context);
          }).paddingOnly(right: 16),
          Stack(
            children: [
              Align(alignment: AlignmentDirectional.center, child: Icon(Icons.notifications)),
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
            NotificationScreen().launch(context);
          }).visible(currentIndex == 0),
          Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.center,
                child: ImageIcon(AssetImage('assets/icons/ic_filter.png'), size: 18, color: Colors.white),
              ),
              Observer(builder: (context) {
                return Positioned(
                  right: 8,
                  top: 16,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  ),
                ).visible(appStore.isFiltering);
              }),
            ],
          ).withWidth(40).onTap(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
              builder: (context) {
                return FilterOrderComponent();
              },
            );
          }).visible(currentIndex == 0),
        ],
      ),
      body: BodyCornerWidget(
        child: [
          OrderFragment(),
          AccountFragment(),
        ][currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appStore.availableBal >= 0 ? colorPrimary : textSecondaryColorGlobal,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (appStore.availableBal >= 0) {
            CreateOrderScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
          } else {
            toast(language.balanceInsufficient);
            WalletScreen().launch(context);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: context.cardColor,
        icons: [Icons.reorder, Icons.person],
        activeIndex: currentIndex,
        gapLocation: GapLocation.center,
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
