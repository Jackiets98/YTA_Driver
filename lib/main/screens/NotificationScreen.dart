import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../utils/Constants.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  String? userID;
  bool mIsLastPage = false;
  List<NotificationData> notificationData = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // if (!mIsLastPage) {
        //
        //
        //   currentPage++;
        //   setState(() {});
        //
        //   init();
        // }
        // Handle registration error
        Fluttertoast.showToast(
          msg: "No More Notification.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      }
    });
  }

  void init() async {
    userID = sharedPreferences.getString('id');
    try {
      // Make an HTTP GET request to your Laravel API
      final url = Uri.parse( mBaseUrl +'getNotification/' + userID!);

      final response = await http.get(
        url,
        headers: headers, // Encode the request body to JSON
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<dynamic> jsonData = json.decode(response.body);

        // Create a list of NotificationData objects from the JSON data
        final List<NotificationData> newNotifications =
        jsonData.map((data) => NotificationData.fromJson(data)).toList();

        setState(() {
          // Add the new notifications to the existing list
          notificationData.addAll(newNotifications);
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.notifications),
      ),
      body: BodyCornerWidget(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              notificationData.isNotEmpty
                  ? ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: notificationData.length,
                      itemBuilder: (_, index) {
                        NotificationData data = notificationData[index];
                        return Container(
                          padding: EdgeInsets.all(12),
                          color: data.createdAt != null ? Colors.transparent : Colors.grey.withOpacity(0.2),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorPrimary.withOpacity(0.15),
                                ),
                                child: Icon(Icons.star, color: colorPrimary, size: 26),
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${data.notificationText}', style: boldTextStyle()).expand(),
                                      8.width,
                                      Text(data.createdAt.validate(), style: secondaryTextStyle()),
                                    ],
                                  ),
                                  8.height,
                                ],
                              ).expand(),
                            ],
                          ).onTap(() async {
                            // bool? res = await OrderDetailScreen(orderData: data.data!.id.validate()).launch(context);
                            // if (res!) {
                            //   currentPage = 1;
                            //   init();
                            // }
                          }),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    )
                  : !appStore.isLoading
                      ? emptyWidget()
                      : SizedBox(),
              loaderWidget().center().visible(appStore.isLoading)
            ],
          );
        }),
      ),
    );
  }
}
