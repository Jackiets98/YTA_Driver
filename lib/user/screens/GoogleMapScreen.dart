import 'dart:convert';

import '../../main/models/CountryListModel.dart';
import '../../main/models/PlaceAddressModel.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'package:flutter/material.dart';

class GoogleMapScreen extends StatefulWidget {
  final bool isPick;

  GoogleMapScreen({this.isPick = true});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool showPlacePickerInContainer = false;
  bool showGoogleMapInContainer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPick ? language.selectPickupLocation : language.selectDeliveryLocation),
      ),
      body: Text('hi')
    );
  }
}
