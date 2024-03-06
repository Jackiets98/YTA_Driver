import 'dart:core';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/PaymentModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/DataProviders.dart';
import '../../main/utils/Widgets.dart';
import '../../user/components/PaymentScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'DashboardScreen.dart';
import 'WalletScreen.dart';

class ReturnOrderScreen extends StatefulWidget {
  static String tag = '/ReturnOrderScreen';
  final OrderData orderData;

  ReturnOrderScreen(this.orderData);

  @override
  ReturnOrderScreenState createState() => ReturnOrderScreenState();
}

class ReturnOrderScreenState extends State<ReturnOrderScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isDeliverNow = true;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;
  bool isCashPayment = true;

  TextEditingController reasonController = TextEditingController();
  String? reason;

  List<PaymentModel> mPaymentList = getPaymentItems();
  int isSelected = 1;

  List<String> returnOrderReasonList = getReturnReasonList();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LiveStream().on('UpdateLanguage', (p0) {
      returnOrderReasonList.clear();
      returnOrderReasonList.addAll(getReturnReasonList());
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  createOrderApiCall() async {
    // appStore.setLoading(true);
    if (formKey.currentState!.validate()) {
      Duration difference = Duration();
      // if (!isDeliverNow) {
      //   DateTime pickFromDateTime = pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
      //   DateTime pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
      //   DateTime deliverFromDateTime = deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
      //   DateTime deliverToDateTime = deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
      //   widget.orderData.deliveryPoint!.startTime = pickFromDateTime.toString();
      //   widget.orderData.deliveryPoint!.endTime = pickToDateTime.toString();
      //   widget.orderData.pickupPoint!.startTime = deliverFromDateTime.toString();
      //   widget.orderData.pickupPoint!.endTime = deliverToDateTime.toString();
      //   difference = pickFromDateTime.difference(deliverFromDateTime);
      // } else {
      //   widget.orderData.pickupPoint!.startTime = DateTime.now().toString();
      //   widget.orderData.pickupPoint!.endTime = null;
      //   widget.orderData.deliveryPoint!.startTime = null;
      //   widget.orderData.deliveryPoint!.endTime = null;
      // }
      if (difference.inMinutes > 0) return toast(language.pickupDeliverValidationMsg);
      // Map req = {
      //   "client_id": widget.orderData.clientId!,
      //   "date": DateTime.now().toString(),
      //   "country_id": widget.orderData.countryId!,
      //   "city_id": widget.orderData.cityId!,
      //   "pickup_point": widget.orderData.deliveryPoint!,
      //   "delivery_point": widget.orderData.pickupPoint!,
      //   "extra_charges": widget.orderData.extraCharges!,
      //   "parcel_type": widget.orderData.parcelType!,
      //   "total_weight": widget.orderData.totalWeight!,
      //   "total_distance": widget.orderData.totalDistance!,
      //   "payment_collect_from": paymentCollectFrom,
      //   "status": ORDER_CREATED,
      //   "payment_type": "",
      //   "payment_status": "",
      //   "fixed_charges": widget.orderData.fixedCharges!,
      //   "parent_order_id": widget.orderData.id!,
      //   "total_amount": widget.orderData.totalAmount??0,
      //   "reason": reason!.validate().trim() != language.other.trim() ? reason : reasonController.text
      // };
      // appStore.setLoading(true);
    }
  }

  /// Save Payment
  Future<void> savePaymentApiCall({String? paymentType, String? totalAmount, String? orderID, String? txnId, String? paymentStatus = PAYMENT_PENDING, Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": orderID,
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": totalAmount,
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    // appStore.setLoading(true);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.returnOrder)),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        scheduleOptionWidget(context, isDeliverNow, 'assets/icons/ic_clock.png', language.deliveryNow).onTap(() {
                          isDeliverNow = true;
                          setState(() {});
                        }).expand(),
                        16.width,
                        scheduleOptionWidget(context, !isDeliverNow, 'assets/icons/ic_schedule.png', language.schedule).onTap(() {
                          isDeliverNow = false;
                          setState(() {});
                        }).expand(),
                      ],
                    ),
                    16.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.pickTime, style: primaryTextStyle()),
                        16.height,
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          child: Column(
                            children: [
                              DateTimePicker(
                                type: DateTimePickerType.date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2050),
                                onChanged: (value) {
                                  pickDate = DateTime.parse(value);
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value!.isEmpty) return errorThisFieldRequired;
                                  return null;
                                },
                                decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                              ),
                              16.height,
                              Row(
                                children: [
                                  Text(language.from, style: primaryTextStyle()).expand(flex: 1),
                                  8.width,
                                  DateTimePicker(
                                    type: DateTimePickerType.time,
                                    onChanged: (value) {
                                      pickFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value.validate().isEmpty) return errorThisFieldRequired;
                                      return null;
                                    },
                                    decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                  ).expand(flex: 2),
                                ],
                              ),
                              16.height,
                              Row(
                                children: [
                                  Text(language.to, style: primaryTextStyle()).expand(flex: 1),
                                  8.width,
                                  DateTimePicker(
                                    type: DateTimePickerType.time,
                                    onChanged: (value) {
                                      pickToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value.validate().isEmpty) return errorThisFieldRequired;
                                      double fromTimeInHour = pickFromTime!.hour + pickFromTime!.minute / 60;
                                      double toTimeInHour = pickToTime!.hour + pickToTime!.minute / 60;
                                      double difference = toTimeInHour - fromTimeInHour;
                                      print(difference);
                                      if (difference <= 0) {
                                        return language.endTimeValidationMsg;
                                      }
                                      return null;
                                    },
                                    decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                  ).expand(flex: 2),
                                ],
                              )
                            ],
                          ),
                        ),
                        16.height,
                        Text(language.deliverTime, style: primaryTextStyle()),
                        16.height,
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          child: Column(
                            children: [
                              DateTimePicker(
                                type: DateTimePickerType.date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2050),
                                onChanged: (value) {
                                  deliverDate = DateTime.parse(value);
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value!.isEmpty) return errorThisFieldRequired;
                                  return null;
                                },
                                decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                              ),
                              16.height,
                              Row(
                                children: [
                                  Text(language.from, style: primaryTextStyle()).expand(flex: 1),
                                  8.width,
                                  DateTimePicker(
                                    type: DateTimePickerType.time,
                                    onChanged: (value) {
                                      deliverFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value.validate().isEmpty) return errorThisFieldRequired;
                                      return null;
                                    },
                                    decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                  ).expand(flex: 2),
                                ],
                              ),
                              16.height,
                              Row(
                                children: [
                                  Text(language.to, style: primaryTextStyle()).expand(flex: 1),
                                  8.width,
                                  DateTimePicker(
                                    type: DateTimePickerType.time,
                                    onChanged: (value) {
                                      deliverToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) return errorThisFieldRequired;
                                      double fromTimeInHour = deliverFromTime!.hour + deliverFromTime!.minute / 60;
                                      double toTimeInHour = deliverToTime!.hour + deliverToTime!.minute / 60;
                                      double difference = toTimeInHour - fromTimeInHour;
                                      if (difference < 0) {
                                        return language.endTimeValidationMsg;
                                      }
                                      return null;
                                    },
                                    decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                  ).expand(flex: 2),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ).visible(!isDeliverNow),
                    16.height,
                    Text(language.payment, style: boldTextStyle()),
                    16.height,
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: mPaymentList.map((mData) {
                        return Container(
                          width: 130,
                          padding: EdgeInsets.all(16),
                          decoration: boxDecorationWithRoundedCorners(
                              border: Border.all(
                                  color: isSelected == mData.index
                                      ? colorPrimary
                                      : appStore.isDarkMode
                                      ? Colors.transparent
                                      : borderColor),
                              backgroundColor: context.cardColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageIcon(AssetImage(mData.image.validate()), size: 20, color: isSelected == mData.index ? colorPrimary : Colors.grey),
                              16.width,
                              Text(mData.title!, style: boldTextStyle()).expand(),
                            ],
                          ),
                        ).onTap(() {
                          isSelected = mData.index!;
                          setState(() {});
                        });
                      }).toList(),
                    ),
                    16.height,
                    Row(
                      children: [
                        Text(language.paymentCollectFrom, style: boldTextStyle()),
                        16.width,
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: paymentCollectFrom,
                          decoration: commonInputDecoration(),
                          items: [
                            DropdownMenuItem(value: PAYMENT_ON_PICKUP, child: Text(language.pickupLocation, style: primaryTextStyle(),maxLines: 1)),
                            DropdownMenuItem(value: PAYMENT_ON_DELIVERY, child: Text(language.deliveryLocation, style: primaryTextStyle(),maxLines: 1)),
                          ],
                          onChanged: (value) {
                            paymentCollectFrom = value!;
                            setState(() {});
                          },
                        ).expand(),
                      ],
                    ).visible(isSelected==1),
                    16.height,
                    Text(language.reason, style: boldTextStyle()),
                    8.height,
                    DropdownButtonFormField<String>(
                      value: reason,
                      isExpanded: true,
                      decoration: commonInputDecoration(),
                      items: returnOrderReasonList.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        reason = val;
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null) return language.fieldRequiredMsg;
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: reasonController,
                      textFieldType: TextFieldType.OTHER,
                      decoration: commonInputDecoration(hintText: language.writeReasonHere),
                      maxLines: 3,
                      minLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) return language.fieldRequiredMsg;
                        return null;
                      },
                    ).visible(reason.validate().trim() == language.other.trim()),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.total, style: boldTextStyle()),
                        16.width,
                        Text('${printAmount(widget.orderData.totalAmount??0)}', style: boldTextStyle(size: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.lblReturn, () {
          createOrderApiCall();
        }),
      ),
    );
  }
}
