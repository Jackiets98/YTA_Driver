import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../main/Chat/ChatScreen.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../user/components/CancelOrderDialog.dart';
import '../../user/screens/ReturnOrderScreen.dart';
import '../../user/screens/UpdateDeliveryStatus.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../main/components/OrderSummeryWidget.dart';
import '../../main/models/OrderDetailModel.dart';
import '../../user/screens/custom_timeline_tile.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final String? orderId;
  final String? itemCode;
  final String? driverPhoneNum;
  final String? customerPhoneNum;
  final String? pickUpLocation;
  final String? dropOffLocation;
  final String? departedTime;
  final String? deliveredTime;
  final String? status;
  final String? itemDesc;
  final int? amount;
  final String? remarks;
  final String? createdAt;
  final String? driverId;

  OrderDetailScreen({
    required this.orderId,
    required this.itemCode,
    required this.itemDesc,
    required this.driverPhoneNum,
    required this.customerPhoneNum,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.departedTime,
    required this.deliveredTime,
    required this.status,
    required this.amount,
    required this.remarks,
    required this.createdAt,
    required this.driverId
  });

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  UserData? userData;
  int rating = 0;
  OrderData? orderData;
  List<OrderHistory>? orderHistory;
  Payment? payment;
  List<ExtraChargeRequestModel> list = [];
  List<CustomTimelineTile> timelineTiles = [];


  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
      fetchUserRating();
    });
  }

  Future<void> init() async {
    orderDetailApiCall();
    fetchDriverTimelines();
  }

  Future<void> fetchDriverTimelines() async {
    final shipmentId = widget.orderId; // Assuming that the order ID matches the shipment ID.
    final apiUrl = Uri.parse(mBaseUrl + 'driverTimelines/$shipmentId');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final driverTimelines = data['driver_timelines'];

        // Call the function to build timeline tiles
        buildTimelineTiles(driverTimelines);

        setState(() {}); // Update the UI
      } else {
        // Handle API errors
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

  Future<void> fetchUserRating() async {
    final url = Uri.parse('https://staging.yessirgps.com/api/get-rating/${widget.orderId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the rating from the API response
      final userRating = int.parse(response.body);
      setState(() {
        rating = userRating;
      });
    } else {
      print('Failed to fetch user rating from Laravel.');
    }
  }


  orderDetailApiCall() async {
    // appStore.setLoading(true);
  }

  userDetailApiCall(int id) async {
    // appStore.setLoading(true);
  }

  void buildTimelineTiles(List<dynamic> driverTimelines) {
    timelineTiles.clear();
    if (driverTimelines != null) {
      for (var timeline in driverTimelines) {
        final isPast = true; // Customize this based on your logic

        // Check if the 'location' and 'created_at' keys exist and are not null
        final location = timeline['location'] != null
            ? timeline['location'] as String
            : 'Location not found';
        final createdAt = timeline['created_at'] != null
            ? timeline['created_at'] as String
            : 'Time not available';
        final id = timeline['id'] != null
            ? timeline['id'] as String
            : 'ID not available';


        final tile = CustomTimelineTile(
          isFirst: timeline == driverTimelines.first,
          isLast: timeline == driverTimelines.last,
          isPast: isPast,
          location: location,
          createdAt: createdAt,
          id: id,
        );

        timelineTiles.add(tile);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    afterBuildCreated(() {
      // appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        finish(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: BodyCornerWidget(
          child: Stack(
            children: [
              // orderData != null?
              Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.orderId, style: boldTextStyle(size: 20)),
                            // Text('#${orderData!.id}', style: boldTextStyle(size: 20)),
                            Text(widget.itemCode!, style: boldTextStyle(size: 20)),
                          ],
                        ),
                        16.height,
                        // Text('${language.createdAt} ${printDate(orderData!.date.toString())}', style: secondaryTextStyle()),
                        Text('${language.createdAt} ${widget.createdAt!}', style: secondaryTextStyle()),
                        Divider(height: 30, thickness: 1),
                        Column(
                          children: [
                            Row(
                              children: [
                                ImageIcon(AssetImage('assets/icons/ic_pick_location.png'), size: 24, color: colorPrimary),
                                16.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${widget.departedTime == null ? 'Not Picked Yet' : '${language.pickedAt} ${widget.departedTime}'}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                    Text('${widget.pickUpLocation}', style: primaryTextStyle()),
                                    Row(
                                      children: [
                                        Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                          commonLaunchUrl('tel:${widget.driverPhoneNum}');
                                        }),
                                        8.width,
                                        Text('${widget.driverPhoneNum}', style: secondaryTextStyle()),
                                      ],
                                    ).paddingOnly(top: 8),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: ReadMoreText(
                                        // '${language.remark}: ${orderData!.pickupPoint!.description.validate()}',
                                        widget.remarks != null ?'${language.remark}: ${widget.remarks}':'${language.remark}: No Remarks',
                                        trimLines: 3,
                                        style: primaryTextStyle(size: 14),
                                        colorClickableText: colorPrimary,
                                        trimMode: TrimMode.Line,
                                        trimCollapsedText: language.showMore,
                                        trimExpandedText: language.showLess,
                                      ),
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ),
                            16.height,
                            Row(
                              children: [
                                ImageIcon(AssetImage('assets/icons/ic_delivery_location.png'), size: 24, color: colorPrimary),
                                16.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // if (orderData!.deliveryDatetime != null)
                                    Text('${widget.deliveredTime == null ? 'Not Delivered Yet' : '${language.deliveredAt} ${widget.deliveredTime}'}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                    Text('${widget.dropOffLocation}', style: primaryTextStyle()),
                                    // if (orderData!.deliveryPoint!.contactNumber != null)
                                    Row(
                                      children: [
                                        Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                          commonLaunchUrl('tel:${widget.customerPhoneNum}');
                                        }),
                                        8.width,
                                        Text('${widget.customerPhoneNum}', style: secondaryTextStyle()),
                                      ],
                                    ).paddingOnly(top: 8),
                                    // if (orderData!.deliveryDatetime == null && orderData!.deliveryPoint!.endTime != null && orderData!.deliveryPoint!.startTime != null)
                                    Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse('2023-09-12 14:00:00').toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse('2023-09-12 14:00:00').toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse('2023-09-12 18:00:00').toLocal())}',
                                        style: secondaryTextStyle())
                                        .paddingOnly(top: 8),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 30, thickness: 1),
                        Text(language.parcelDetails, style: boldTextStyle(size: 16)),
                        12.height,
                        Container(
                          decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), backgroundColor: Colors.transparent),
                                    padding: EdgeInsets.all(8),
                                    child: Image.asset(parcelTypeIcon('Box'.validate()), height: 24, width: 24, color: Colors.grey),
                                  ),
                                  8.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${widget.itemDesc}'.validate(), style: boldTextStyle()),
                                      4.height,
                                      Text('2.0 ton', style: secondaryTextStyle()),
                                    ],
                                  ).expand(),
                                ],
                              ),
                              Divider(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Number of item', style: primaryTextStyle()),
                                  Text('${widget.amount}', style: primaryTextStyle()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        24.height,
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Visibility(
                            visible: widget.status == '1', // Show the button if the status is '1'
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add your update functionality here
                                      // For example, navigate to UpdateDeliveryStatus.dart
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => UpdateDeliveryStatus(
                                            shipmentId: widget.orderId!,
                                            driverId: widget.driverId!,
                                            status: widget.status!,
                                            itemCode: widget.itemCode!,
                                            driverPhoneNum: widget.driverPhoneNum,
                                            customerPhoneNum: widget.customerPhoneNum,
                                            pickUpLocation: widget.pickUpLocation,
                                            dropOffLocation: widget.dropOffLocation,
                                            departedTime: widget.departedTime,
                                            deliveredTime: widget.deliveredTime,
                                            itemDesc: widget.itemDesc,
                                            amount: widget.amount,
                                            remarks: widget.remarks,
                                            createdAt: widget.createdAt,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('UPDATE'),
                                  ),
                                ),
                                30.height, // Add spacing
                                Divider(height: 30, thickness: 1), // Display the divider
                              ],
                            ),
                          ),
                        ),
                        30.height,
                        Divider(height: 30, thickness: 1),
                        Column(
                          children: [
                            if (timelineTiles.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Delivery Timelines',
                                  style: boldTextStyle(size: 21),
                                ),
                              ),
                            ListView.builder(
                              itemCount: timelineTiles.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return timelineTiles[index];
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        widget.status! == '2' ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                              child: Text(
                                'Your Rating',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final filled = index < rating;
                                return Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  color: filled ? Colors.yellow : Colors.grey,
                                  size: 40,
                                );
                              }),
                            ),
                          ],
                        ): SizedBox(height: 1,)

                      ],
                    ),
                  ),
                ],
              ),
              Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}
