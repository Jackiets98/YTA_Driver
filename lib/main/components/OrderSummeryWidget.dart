import 'package:flutter/material.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../models/OrderDetailModel.dart';
import '../utils/Constants.dart';

class OrderSummeryWidget extends StatefulWidget {
  static String tag = '/OrderSummeryWidget';

  final List<ExtraChargeRequestModel> extraChargesList;
  final num totalDistance;
  final num totalWeight;
  final num distanceCharge;
  final num weightCharge;
  final num totalAmount;
  final String? status;
  final Payment? payment;

  OrderSummeryWidget({
    required this.extraChargesList,
    required this.totalDistance,
    required this.totalWeight,
    required this.distanceCharge,
    required this.weightCharge,
    required this.totalAmount,
    this.status,
    this.payment,
  });

  @override
  OrderSummeryWidgetState createState() => OrderSummeryWidgetState();
}

class OrderSummeryWidgetState extends State<OrderSummeryWidget> {
  num fixedCharges = 0;
  num minDistance = 0;
  num minWeight = 0;
  num perDistanceCharges = 0;
  num perWeightCharges = 0;
  List<ExtraChargeRequestModel> extraList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    widget.extraChargesList.forEach((element) {
      if (element.key == FIXED_CHARGES) {
        fixedCharges = element.value!;
      } else if (element.key == MIN_DISTANCE) {
        minDistance = element.value!;
      } else if (element.key == MIN_WEIGHT) {
        minWeight = element.value!;
      } else if (element.key == PER_DISTANCE_CHARGE) {
        perDistanceCharges = element.value!;
      } else if (element.key == PER_WEIGHT_CHARGE) {
        perWeightCharges = element.value!;
      } else {
        extraList.add(element);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.deliveryCharge, style: primaryTextStyle()),
            16.width,
            Text('${printAmount(fixedCharges)}', style: primaryTextStyle()),
          ],
        ),
        Column(
          children: [
            8.height,
            Row(
              children: [
                Text(language.distanceCharge, style: primaryTextStyle()),
                4.width,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('(${(widget.totalDistance - minDistance).toStringAsFixed(digitAfterDecimal)}', style: secondaryTextStyle()),
                    Icon(Icons.close, color: Colors.grey, size: 12),
                    Text('$perDistanceCharges)', style: secondaryTextStyle()),
                  ],
                ).expand(),
                16.width,
                Text('${printAmount(widget.distanceCharge)}', style: primaryTextStyle()),
              ],
            )
          ],
        ).visible(widget.distanceCharge != 0),
        Column(
          children: [
            8.height,
            Row(
              children: [
                Text(language.weightCharge, style: primaryTextStyle()),
                4.width,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('(${widget.totalWeight - minWeight}', style: secondaryTextStyle()),
                    Icon(Icons.close, color: Colors.grey, size: 12),
                    Text('$perWeightCharges)', style: secondaryTextStyle()),
                  ],
                ).expand(),
                16.width,
                Text('${printAmount(widget.weightCharge)}', style: primaryTextStyle()),
              ],
            ),
          ],
        ).visible(widget.weightCharge != 0),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            children: [
              8.height,
              Text('${printAmount((fixedCharges + widget.distanceCharge + widget.weightCharge).toStringAsFixed(digitAfterDecimal).toDouble())}', style: primaryTextStyle()),
            ],
          ),
        ).visible((widget.weightCharge != 0 || widget.distanceCharge != 0) && extraList.length != 0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(language.extraCharges, style: boldTextStyle()),
            8.height,
            Column(
                children: List.generate(extraList.length, (index) {
              ExtraChargeRequestModel mData = extraList.elementAt(index);
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(mData.key!.replaceAll("_", " ").capitalizeFirstLetter(), style: primaryTextStyle()),
                    4.width,
                    Text('(${mData.valueType == CHARGE_TYPE_PERCENTAGE ? '${mData.value}%' : '${printAmount(mData.value.validate())}'})', style: secondaryTextStyle()).expand(),
                    16.width,
                    Text('${printAmount(countExtraCharge(totalAmount: (fixedCharges + widget.weightCharge + widget.distanceCharge), chargesType: mData.valueType!, charges: mData.value!))}', style: primaryTextStyle()),
                  ],
                ),
              );
            }).toList()),
          ],
        ).visible(extraList.length != 0),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.total, style: boldTextStyle(size: 20)),
            (widget.status.validate() == ORDER_CANCELLED && widget.payment != null && widget.payment!.deliveryManFee == 0)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${printAmount(widget.totalAmount.validate())}', style: secondaryTextStyle(size: 16,decoration: TextDecoration.lineThrough)),
                      8.width,
                      Text('${printAmount(widget.payment!.cancelCharges.validate())}', style: boldTextStyle(size: 20)),
                    ],
                  )
                : Text('${printAmount(widget.totalAmount.validate())}', style: boldTextStyle(size: 20)),
          ],
        ),
      ],
    );
  }
}
