import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderTrackingScreen extends StatefulWidget {
  static String tag = '/OrderTrackingScreen';

  final OrderData orderData;

  OrderTrackingScreen({required this.orderData});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? timer;

  double cameraZoom = 13;

  double cameraTilt = 0;
  double cameraBearing = 30;

  UserData? deliveryBoyData;


  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getDeliveryBoyDetails());
  }

  getDeliveryBoyDetails() {

  }


  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.trackOrder)),
      body: Text('hi')
    );
  }
}
