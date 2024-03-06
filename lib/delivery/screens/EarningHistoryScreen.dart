import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/UserProfileDetailModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';

class EarningHistoryScreen extends StatefulWidget {
  @override
  EarningHistoryScreenState createState() => EarningHistoryScreenState();
}

class EarningHistoryScreenState extends State<EarningHistoryScreen> {
  ScrollController scrollController = ScrollController();
  List<EarningData> earningList = [];
  EarningDetail earningDetail = EarningDetail();

  int currentPage = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  getUserDetailApiCall() async {
    // appStore.setLoading(true);

  }

  void init() async {
    getUserDetailApiCall();
    getPaymentListApi();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          getPaymentListApi();
        }
      }
    });
  }

  getPaymentListApi() async {
    appStore.setLoading(true);

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.earningHistory)),
      body: Stack(
        children: [
          BodyCornerWidget(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary),
                        padding: EdgeInsets.all(16),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(language.earning, style: primaryTextStyle(size: 16, color: white.withOpacity(0.7)),textAlign: TextAlign.center),
                                  6.height,
                                  Text('${printAmount(earningDetail.deliveryManCommission ?? 0)}', style: boldTextStyle(size: 20, color: Colors.white),textAlign: TextAlign.center),
                                ],
                              ).expand(),
                              VerticalDivider(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(language.adminCommission, style: primaryTextStyle(size: 16, color: white.withOpacity(0.7)),textAlign: TextAlign.center),
                                  6.height,
                                  Text('${printAmount(earningDetail.adminCommission ?? 0)}', style: boldTextStyle(size: 20, color: Colors.white),textAlign: TextAlign.center),
                                ],
                              ).expand(),
                            ],
                          ),
                        ),
                      ),
                      16.height,
                      ListView.builder(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: earningList.length,
                        shrinkWrap: true,
                          itemBuilder: (_, index) {
                            EarningData data = earningList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(8),
                              decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: context.cardColor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('${language.orderId}: #${data.orderId}', style: boldTextStyle()),
                                      Spacer(),
                                      Text(
                                        '${data.paymentType}',
                                        style: primaryTextStyle(),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(printDate(data.createdAt.validate()), style: secondaryTextStyle()),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        language.earning,
                                        textAlign: TextAlign.center,
                                        style: primaryTextStyle(size: 14),
                                      ),
                                      Text('${printAmount(data.deliveryManCommission ?? 0)}', style: boldTextStyle(size: 15)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        language.adminCommission,
                                        textAlign: TextAlign.center,
                                        style: primaryTextStyle(size: 14),
                                      ),
                                      Text('${printAmount(data.adminCommission ?? 0)}', style: boldTextStyle(size: 15)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
