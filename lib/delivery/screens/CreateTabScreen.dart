import 'dart:convert';
import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../delivery/screens/ReceivedScreenOrderScreen.dart';
import '../../main/models/OrderListModel.dart';
import 'package:http/http.dart' as http;
import '../../main/screens/LoginScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../user/screens/OrderDetailScreen.dart';

class CreateTabScreen extends StatefulWidget {
  final String? orderStatus;

  CreateTabScreen({this.orderStatus});

  @override
  CreateTabScreenState createState() => CreateTabScreenState();
}

class CreateTabScreenState extends State<CreateTabScreen> {
  ScrollController scrollController = ScrollController();
  bool isDone = false;
  String? savedID;
  int itemCountToShow = 3;

  List<OrderData> orderData = [];

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var obtainedID = sharedPreferences.getString('id');
    var deviceID = sharedPreferences.getString('androidID');
    var statusCode;

    if(widget.orderStatus == ORDER_DELIVERED) {
      statusCode = '2';
    }else if(widget.orderStatus == ORDER_ASSIGNED){
      statusCode = '0';
    }else if(widget.orderStatus == ORDER_ACCEPTED){
      statusCode = '1';
    }
    final url = Uri.parse(mBaseUrl + 'shipmentList/' + obtainedID! + '/' + statusCode);

    final response = await http.get(
      url,
      headers: headers, // Encode the request body to JSON
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(responseData['shipments']);
        // Create a list to hold the parsed OrderData objects
        final List<OrderData> parsedOrders = [];

        // Iterate through the 'orders' list and parse each order
        for (final order in orders) {
          if(order['device_id'] != deviceID){
            print(deviceID);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => LoginScreen()), (route) => false);

            // Handle registration error
            Fluttertoast.showToast(
              msg: "Your account has been login from another device.",
              toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
              gravity: ToastGravity.BOTTOM, // Position of the toast message
              timeInSecForIosWeb: 1, // Only for iOS and web
              backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
              textColor: Colors.white, // Text color of the toast
              fontSize: 16.0, // Font size of the text
            );
          }else{
          final OrderData orderData = OrderData(
            // Parse order properties from the 'order' Map
            // Replace these lines with the actual property names in your JSON data
            id: order['item_code'],
            item_desc: order['item_description'],
            totalAmount: order['amount'],
            status: order['delivery_status'],
            deliveryManName: order['name'],
            deliveryDatetime: order['delivered_time'],
            departedDateTime: order['departed_time'],
            clientName: order['last_name'],
            reason: order['remarks'],
            deliveryPoint: order['c_address'],
            pickupPoint: order['d_address'],
            contactNumber: order['phone_no'],
            parentOrderId: order['id'],
            driverContact: order['phone_num'],
            pickupDatetime: order['created_at'],
            deliveryManId: order['driver']
            // Parse other properties as needed
          );

          parsedOrders.add(orderData);
          }
        }

        // Update the 'orderData' list with the parsed orders
        setState(() {
          orderData = parsedOrders;

        });

      } else {
        // Handle HTTP request error
        Fluttertoast.showToast(
          msg: "There is an error occurred.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      }
    } else {
      // Handle HTTP request error
      Fluttertoast.showToast(
        msg: "Something Went Wrong",
        toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
        gravity: ToastGravity.BOTTOM, // Position of the toast message
        timeInSecForIosWeb: 1, // Only for iOS and web
        backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the text
      );
    }
  }

  void _showConfirmationDialog({String? savedID}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to start this delivery?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                var url = Uri.parse(mBaseUrl + 'updateStatusForDelivery/' + savedID!);

                final response = await http.post(
                  url,
                  body: {'status': '1'},
                );

                if (response.statusCode == 200) {
                  Fluttertoast.showToast(
                    msg: "Status Updated",
                    toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
                    gravity: ToastGravity.BOTTOM, // Position of the toast message
                    timeInSecForIosWeb: 1, // Only for iOS and web
                    backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
                    textColor: Colors.white, // Text color of the toast
                    fontSize: 16.0, // Font size of the text
                  );

                  init();
                } else {
                  // Handle registration error
                  Fluttertoast.showToast(
                    msg: "There is an error occurred.",
                    toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
                    gravity: ToastGravity.BOTTOM, // Position of the toast message
                    timeInSecForIosWeb: 1, // Only for iOS and web
                    backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
                    textColor: Colors.white, // Text color of the toast
                    fontSize: 16.0, // Font size of the text
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeliverDialog({String? savedID}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to complete this delivery?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                var url = Uri.parse(mBaseUrl + 'updateStatusForDelivery/' + savedID!);

                final response = await http.post(
                  url,
                  body: {'status': '2'},
                );

                if (response.statusCode == 200) {
                  Fluttertoast.showToast(
                    msg: "Status Updated",
                    toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
                    gravity: ToastGravity.BOTTOM, // Position of the toast message
                    timeInSecForIosWeb: 1, // Only for iOS and web
                    backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
                    textColor: Colors.white, // Text color of the toast
                    fontSize: 16.0, // Font size of the text
                  );

                  init();
                } else {
                  // Handle registration error
                  Fluttertoast.showToast(
                    msg: "There is an error occurred.",
                    toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
                    gravity: ToastGravity.BOTTOM, // Position of the toast message
                    timeInSecForIosWeb: 1, // Only for iOS and web
                    backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
                    textColor: Colors.white, // Text color of the toast
                    fontSize: 16.0, // Font size of the text
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    init();

    // Add a listener to the scrollController
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // User reached the end of the list, load more items
        setState(() {
          itemCountToShow += 3; // Increase the number of items to show by 3
        });
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        init();
      },
      child:Observer(
        builder: (_) => Stack(
          children: [
            ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              shrinkWrap: true,
              itemCount: min(orderData.length, itemCountToShow),
              itemBuilder: (_, index) {
                OrderData data = orderData[index];
                return GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: boxDecorationRoundedWithShadow(
                      defaultRadius.toInt(),
                      spreadRadius: 20.0, // Custom spread radius
                      blurRadius: 20.0, // Custom blur radius
                      backgroundColor: context.cardColor,
                      shadowColor: appStore.isDarkMode ? Colors.transparent : null,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${language.order}# ${data.id}', style: boldTextStyle(size: 16)).expand(),
                            // AppButton(
                            //   margin: EdgeInsets.only(right: 10),
                            //   elevation: 0,
                            //   text: language.cancel,
                            //   padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            //   textStyle: boldTextStyle(color: Colors.red),
                            //   color: Colors.red.withOpacity(0.2),
                            //   onTap: () {
                            //     showConfirmDialogCustom(
                            //       context,
                            //       primaryColor: Colors.red,
                            //       dialogType: DialogType.CONFIRMATION,
                            //       title: language.orderCancelConfirmation,
                            //       positiveText: language.yes,
                            //       negativeText: language.no,
                            //       onAccept: (c) async {
                            //
                            //       },
                            //     );
                            //   },
                            // ).visible( data.status == '0'),
                            widget.orderStatus != ORDER_CANCELLED
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: TextButton(
                                      child: Text(data.status == '1' ? 'Delivering' : 'To Be Delivered', style: TextStyle(color:data.status == '1' ? Colors.green : Colors.orange)),
                                    style: TextButton.styleFrom(foregroundColor: colorPrimary, ),
                                      onPressed: () {
                                        savedID = data.parentOrderId;
                                        if (data.status == '0') {
                                          _showConfirmationDialog(savedID: savedID);
                                        } else if(data.status == '1'){
                                          _showDeliverDialog(savedID: savedID);
                                        }
                                      },
                                    ).visible(widget.orderStatus != ORDER_DELIVERED),
                                )
                                : SizedBox()
                          ],
                        ),
                        Divider(height: 30, thickness: 1),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.pickupDatetime != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.picked, style: boldTextStyle(size: 18)),
                                  4.height,
                                  Text('${language.at} ${printDate(data.pickupDatetime!)}', style: secondaryTextStyle()),
                                  16.height,
                                ],
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ImageIcon(AssetImage('assets/icons/ic_pick_location.png'), size: 24, color: colorPrimary),
                                12.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${data.pickupPoint}', style: primaryTextStyle()),
                                  ],
                                ).expand(),
                                12.width,
                              ],
                            ),
                          ],
                        ),
                        DottedLine(dashColor: borderColor).paddingSymmetric(vertical: 16, horizontal: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data.deliveryDatetime != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.delivered, style: boldTextStyle(size: 18)),
                                  4.height,
                                  Text('${language.at} ${printDate(data.deliveryDatetime!)}', style: secondaryTextStyle()),
                                  16.height,
                                ],
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ImageIcon(AssetImage('assets/icons/ic_delivery_location.png'), size: 24, color: colorPrimary),
                                12.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${data.deliveryPoint}', style: primaryTextStyle()),
                                  ],
                                ).expand(),
                                12.width,
                                if (data.contactNumber != null)
                                  Image.asset('assets/icons/ic_call.png', width: 24, height: 24).onTap(() {
                                    // Construct the phone dialing URL
                                    final phoneUrl = 'tel:0${data.contactNumber}';

                                    launch(phoneUrl) // Use the url_launcher package to launch the phone dialer
                                        .then((value) {})
                                        .catchError((e) {
                                      print('Error launching phone dialer: $e');
                                    });
                                  }),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 30, thickness: 1),
                        Row(
                          children: [
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                                backgroundColor: Colors.transparent,
                              ),
                              padding: EdgeInsets.all(8),
                              child: Image.asset(parcelTypeIcon(data.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
                            ),
                            8.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.item_desc!, style: boldTextStyle()),
                                4.height,
                                Row(
                                  children: [
                                    data.deliveryDatetime != null ? Text(printDate(data.deliveryDatetime ?? ''), style: secondaryTextStyle()).expand() : SizedBox(),
                                    Text('${(data.totalAmount)}', style: boldTextStyle()),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: AppButton(
                                elevation: 0,
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  side: BorderSide(color: colorPrimary),
                                ),
                                child: Text(language.notifyUser, style: primaryTextStyle(color: colorPrimary)),
                                onTap: () {
                                  showConfirmDialogCustom(
                                    context,
                                    primaryColor: colorPrimary,
                                    dialogType: DialogType.CONFIRMATION,
                                    title: language.areYouSureWantToArrive,
                                    positiveText: language.yes,
                                    negativeText: language.cancel,
                                    onAccept: (c) async {
                                      appStore.setLoading(true);
                                      appStore.setLoading(false);
                                      finish(context);
                                      init();
                                    },
                                  );
                                },
                              ),
                            ).paddingOnly(top: 12, right: 16).visible(data.status == ORDER_ACCEPTED),
                            Align(
                                alignment: Alignment.topRight,
                                child: AppButton(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  padding: EdgeInsets.all(6),
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                    side: BorderSide(color: colorPrimary),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(language.trackOrder, style: primaryTextStyle(color: colorPrimary)),
                                      Icon(Icons.arrow_right, color: colorPrimary),
                                    ],
                                  ),
                                  onTap: () async {

                                  },
                                )).paddingOnly(top: 12).visible(data.status == ORDER_DEPARTED || data.status == ORDER_ACCEPTED),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    OrderDetailScreen(orderId: data.parentOrderId, itemCode: data.id, itemDesc: data.item_desc, driverPhoneNum: data.driverContact, customerPhoneNum: data.contactNumber, pickUpLocation: data.pickupPoint, dropOffLocation: data.deliveryPoint, departedTime: data.departedDateTime, deliveredTime: data.deliveryDatetime, status: data.status, amount: data.totalAmount, remarks: data.reason, createdAt: data.pickupDatetime, driverId: data.deliveryManId).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
                  },
                );
              },
            ),
            if (orderData.isEmpty) appStore.isLoading ? SizedBox() : emptyWidget(),
            loaderWidget().visible(appStore.isLoading)
          ],
        ),
      ),
    );
  }

  Future<void> onTapData({required String orderStatus, required OrderData orderData}) async {
    if (orderStatus == ORDER_ASSIGNED) {
      init();
    } else if (orderStatus == ORDER_DELIVERED) {
      await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
          .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    }
  }
  //
  // buttonText(String orderStatus) {
  //   if (orderStatus == ORDER_ASSIGNED) {
  //     return language.active;
  //   } else if (orderStatus == ORDER_ACCEPTED) {
  //     return language.pickUp;
  //   } else if (orderStatus == ORDER_ARRIVED) {
  //     return language.pickUp;
  //   } else if (orderStatus == ORDER_PICKED_UP) {
  //     return language.departed;
  //   } else if (orderStatus == ORDER_DEPARTED) {
  //     return language.confirmDelivery;
  //   }
  //   return '';
  // }
}
