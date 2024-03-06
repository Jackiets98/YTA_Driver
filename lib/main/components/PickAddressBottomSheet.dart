import 'dart:convert';
import 'package:flutter/material.dart';
import '../../main/models/PlaceAddressModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../user/screens/GoogleMapScreen.dart';

class PickAddressBottomSheet extends StatefulWidget {
  final Function(PlaceAddressModel) onPick;
  final bool isPickup;

  PickAddressBottomSheet({required this.onPick, this.isPickup = true});

  @override
  PickAddressBottomSheetState createState() => PickAddressBottomSheetState();
}

class PickAddressBottomSheetState extends State<PickAddressBottomSheet> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: colorPrimary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.isPickup ? language.choosePickupAddress : language.chooseDeliveryAddress, style: boldTextStyle()),
                8.height,
                Text(language.showingAllAddress, style: secondaryTextStyle()),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: colorPrimary),
              10.width,
              Text(language.addNewAddress, style: boldTextStyle(color: colorPrimary)),
            ],
          ).onTap(() async {
            PlaceAddressModel? res = await GoogleMapScreen(isPick: widget.isPickup).launch(context);
            if (res != null) {
              widget.onPick.call(res);
              finish(context);
            }
          }).paddingAll(16),
          Divider(),
          ListView.separated(
            shrinkWrap: true,
            itemCount: (getStringListAsync(RECENT_ADDRESS_LIST) ?? []).length,
            itemBuilder: (context, index) {
              int len = (getStringListAsync(RECENT_ADDRESS_LIST) ?? []).length;
              PlaceAddressModel mData = PlaceAddressModel.fromJson(jsonDecode(getStringListAsync(RECENT_ADDRESS_LIST)![len - index - 1]));
              return Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  10.width,
                  Text('${mData.placeAddress}', style: primaryTextStyle(), maxLines: 2).expand(),
                  10.width,
                  Icon(Icons.highlight_remove_outlined, color: Colors.red).onTap(() {
                    List<String> list = getStringListAsync(RECENT_ADDRESS_LIST) ?? [];
                    list.removeWhere((element) => PlaceAddressModel.fromJson(jsonDecode(element)).placeId == mData.placeId);
                    setValue(RECENT_ADDRESS_LIST, list);
                    setState(() {});
                  })
                ],
              ).onTap(() async {
                widget.onPick.call(mData);
                finish(context);
              }).paddingSymmetric(vertical: 8, horizontal: 16);
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ).expand(),
        ],
      ),
    );
  }
}
