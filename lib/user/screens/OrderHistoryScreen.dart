import 'package:flutter/material.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../main.dart';
import '../../main/models/OrderDetailModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';

class OrderHistoryScreen extends StatefulWidget {
  static String tag = '/OrderHistoryScreen';

  final List<OrderHistory> orderHistory;

  OrderHistoryScreen({required this.orderHistory});

  @override
  OrderHistoryScreenState createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.orderHistory),
      ),
      body: Observer(builder :(context) {
        return BodyCornerWidget(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: widget.orderHistory.length,
            itemBuilder: (context, index) {
              OrderHistory mData = widget.orderHistory[index];
              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: index == 0 ? true : false,
                isLast: index == (widget.orderHistory.length - 1)
                    ? true
                    : false,
                indicatorStyle: IndicatorStyle(width: 15, color: colorPrimary),
                afterLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                beforeLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                endChild: Row(
                  children: [
                    ImageIcon(AssetImage(
                        statusTypeIcon(type: mData.historyType)),
                        color: colorPrimary, size: 30),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${mData.historyType!
                                .replaceAll("_", " ")
                                .capitalizeFirstLetter()}',
                            style: boldTextStyle()),
                        8.height,
                        Text(messageData(mData)),
                        8.height,
                        Text('${printDate('${mData.createdAt}')}',
                            style: secondaryTextStyle()),
                      ],
                    ).expand(),
                  ],
                ).paddingAll(12),
              );
            },
          ),
        );

      }  ),
    );
  }


  messageData(OrderHistory orderData) {
    if (getStringAsync(USER_TYPE) == CLIENT) {
      if (orderData.historyType == ORDER_ASSIGNED) {
        return 'Your Order#${orderData.orderId} has been assigned to ${orderData.historyData!.deliveryManName}.';
      } else if (orderData.historyType == ORDER_TRANSFER) {
        return 'Your Order#${orderData.orderId} has been transfered to ${orderData.historyData!.deliveryManName}.';
      } else {
        return '${orderData.historyMessage}';
      }
    } else {
      return '${orderData.historyMessage}';
    }
  }
}
