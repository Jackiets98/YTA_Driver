import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class TrackingScreen extends StatefulWidget {


  @override
  TrackingScreenState createState() => TrackingScreenState();
}

class TrackingScreenState extends State<TrackingScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.trackingOrder),
      ),
      body: Text('hi'),
    );
  }
}
