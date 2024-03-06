import 'dart:core';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/ParcelTypeListModel.dart';
import '../../main/models/PaymentModel.dart';
import '../../main/models/VehicleModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../user/components/CreateOrderConfirmationDialog.dart';
import '../../user/components/PaymentScreen.dart';
import '../../user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main/components/OrderSummeryWidget.dart';
import '../../main/components/PickAddressBottomSheet.dart';
import '../../main/models/AutoCompletePlacesListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/PlaceIdDetailModel.dart';
import 'WalletScreen.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/CreateOrderScreen';

  final OrderData? orderData;

  CreateOrderScreen({this.orderData});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityModel? cityData;
  List<ParcelTypeData> parcelTypeList = [];

  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController(text: '1');
  TextEditingController totalParcelController = TextEditingController(text: '1');

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();

  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();
  TextEditingController deliverDateController = TextEditingController();
  TextEditingController deliverFromTimeController = TextEditingController();
  TextEditingController deliverToTimeController = TextEditingController();

  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();

  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  DateTime? pickFromDateTime, pickToDateTime, deliverFromDateTime, deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;

  bool isDeliverNow = true;
  int isSelected = 1;

  bool? isCash = false;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;

  List<PaymentModel> mPaymentList = getPaymentItems();

  List<ExtraChargeRequestModel> extraChargeList = [];

  int? selectedVehicle;
  List<VehicleData> vehicleList = [];
  VehicleData? vehicleData;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    await getCityDetailApiCall(getIntAsync(CITY_ID));
    getParcelTypeListApiCall();
    extraChargesList();


    // if (widget.orderData != null) {
    //   if (widget.orderData!.totalWeight != 0) weightController.text = widget.orderData!.totalWeight!.toString();
    //   if (widget.orderData!.totalParcel != null) totalParcelController.text = widget.orderData!.totalParcel!.toString();
    //   parcelTypeCont.text = widget.orderData!.parcelType.validate();
    //
    //   pickAddressCont.text = widget.orderData!.pickupPoint!.address.validate();
    //   pickLat = widget.orderData!.pickupPoint!.latitude.validate();
    //   pickLong = widget.orderData!.pickupPoint!.longitude.validate();
    //   if (widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").length == 1) {
    //     pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").last;
    //   } else {
    //     pickupCountryCode = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").first;
    //     pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").last;
    //   }
    //   pickDesCont.text = widget.orderData!.pickupPoint!.description.validate();
    //
    //   deliverAddressCont.text = widget.orderData!.deliveryPoint!.address.validate();
    //   deliverLat = widget.orderData!.deliveryPoint!.latitude.validate();
    //   deliverLong = widget.orderData!.deliveryPoint!.longitude.validate();
    //   if (widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").length == 1) {
    //     deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").last;
    //   } else {
    //     deliverCountryCode = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").first;
    //     deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").last;
    //   }
    //   deliverDesCont.text = widget.orderData!.deliveryPoint!.description.validate();
    //
    //   paymentCollectFrom = widget.orderData!.paymentCollectFrom.validate(value: PAYMENT_ON_PICKUP);
    // }
  }

  extraChargesList() {
    extraChargeList.clear();
    extraChargeList.add(ExtraChargeRequestModel(key: FIXED_CHARGES, value: cityData!.fixedCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_DISTANCE, value: cityData!.minDistance, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_WEIGHT, value: cityData!.minWeight, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: PER_DISTANCE_CHARGE, value: cityData!.perDistanceCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: PER_WEIGHT_CHARGE, value: cityData!.perWeightCharges, valueType: ""));
    cityData!.extraCharges!.forEach((element) {
      extraChargeList.add(ExtraChargeRequestModel(key: element.title!.toLowerCase().replaceAll(' ', "_"), value: element.charges, valueType: element.chargesType));
    });
  }

  getCityDetailApiCall(int cityId) async {

  }

  getParcelTypeListApiCall() async {
    // appStore.setLoading(true);

  }

  getVehicleApiCall({String? name}) async {
    // appStore.setLoading(true);
  }

  getTotalAmount() {
    totalDistance = calculateDistance(pickLat.toDouble(), pickLong.toDouble(), deliverLat.toDouble(), deliverLong.toDouble());
    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;

    /// calculate weight Charge
    if (weightController.text.toDouble() > cityData!.minWeight!) {
      weightCharge = ((weightController.text.toDouble() - cityData!.minWeight!) * cityData!.perWeightCharges!).toStringAsFixed(digitAfterDecimal).toDouble();
    }

    /// calculate distance Charge
    if (totalDistance > cityData!.minDistance!) {
      distanceCharge = ((totalDistance - cityData!.minDistance!) * cityData!.perDistanceCharges!).toStringAsFixed(digitAfterDecimal).toDouble();
    }

    /// total amount
    totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      totalExtraCharge += countExtraCharge(totalAmount: totalAmount, charges: element.charges!, chargesType: element.chargesType!);
    });

    /// All Charges
    totalAmount = (totalAmount + totalExtraCharge).toStringAsFixed(digitAfterDecimal).toDouble();
  }

  createOrderApiCall(String orderStatus) async {
    // appStore.setLoading(true);
    Map req = {
      "id": widget.orderData != null ? widget.orderData!.id : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      if (appStore.isVehicleOrder != 0) "vehicle_id": selectedVehicle.toString(),
      "pickup_point": {
        "start_time": (!isDeliverNow && pickFromDateTime != null) ? pickFromDateTime.toString() : DateTime.now().toString(),
        "end_time": (!isDeliverNow && pickToDateTime != null) ? pickToDateTime.toString() : null,
        "address": pickAddressCont.text,
        "latitude": pickLat,
        "longitude": pickLong,
        "description": pickDesCont.text,
        "contact_number": '$pickupCountryCode ${pickPhoneCont.text.trim()}'
      },
      "delivery_point": {
        "start_time": (!isDeliverNow && deliverFromDateTime != null) ? deliverFromDateTime.toString() : null,
        "end_time": (!isDeliverNow && deliverToDateTime != null) ? deliverToDateTime.toString() : null,
        "address": deliverAddressCont.text,
        "latitude": deliverLat,
        "longitude": deliverLong,
        "description": deliverDesCont.text,
        "contact_number": '$deliverCountryCode ${deliverPhoneCont.text.trim()}',
      },
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": weightController.text.toDouble(),
      "total_distance": totalDistance.toStringAsFixed(digitAfterDecimal).validate(),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge": weightCharge,
      "distance_charge": distanceCharge,
      "total_parcel": totalParcelController.text.toInt(),
    };

    log("req----" + req.toString());

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

  Future<List<Predictions>> getPlaceAutoCompleteApiCall(String text) async {
    List<Predictions> list = [];

    return list;
  }

  Future<PlaceIdDetailModel?> getPlaceIdDetailApiCall({required String placeId}) async {
    PlaceIdDetailModel? detailModel;
    return detailModel;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget createOrderWidget1() {
    return Observer(builder: (context) {
      return Column(
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
              Text(language.pickTime, style: boldTextStyle()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), borderRadius: BorderRadius.circular(defaultRadius)),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: pickDateController,
                      type: DateTimePickerType.date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                      onChanged: (value) {
                        pickDate = DateTime.parse(value);
                        deliverDate = null;
                        deliverDateController.clear();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                      decoration: commonInputDecoration(suffixIcon: Icons.calendar_today, hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: pickFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            pickFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: pickToTimeController,
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
                            if (difference <= 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              Text(language.deliverTime, style: boldTextStyle()),
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
                      controller: deliverDateController,
                      type: DateTimePickerType.date,
                      initialDate: pickDate ?? DateTime.now(),
                      firstDate: pickDate ?? DateTime.now(),
                      lastDate: DateTime(2050),
                      onChanged: (value) {
                        deliverDate = DateTime.parse(value);
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                      decoration: commonInputDecoration(suffixIcon: Icons.calendar_today, hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: deliverFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            deliverFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: deliverToTimeController,
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
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).visible(!isDeliverNow),
          16.height,
          Text(language.weight, style: boldTextStyle()),
          8.height,
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), borderRadius: BorderRadius.circular(defaultRadius)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(language.weight, style: primaryTextStyle()).paddingAll(12).expand(),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.remove, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    if (weightController.text.toDouble() > 1) {
                      weightController.text = (weightController.text.toDouble() - 1).toString();
                    }
                  }),
                  VerticalDivider(thickness: 1),
                  Container(
                    width: 50,
                    child: AppTextField(
                      controller: weightController,
                      textAlign: TextAlign.center,
                      maxLength: 5,
                      textFieldType: TextFieldType.PHONE,
                      decoration: InputDecoration(
                        counterText: '',
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.add, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    weightController.text = (weightController.text.toDouble() + 1).toString();
                  }),
                ],
              ),
            ),
          ),
          16.height,
          Text(language.numberOfParcels, style: boldTextStyle()),
          8.height,
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), borderRadius: BorderRadius.circular(defaultRadius)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(language.numberOfParcels, style: primaryTextStyle()).paddingAll(12).expand(),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.remove, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    if (totalParcelController.text.toInt() > 1) {
                      totalParcelController.text = (totalParcelController.text.toInt() - 1).toString();
                    }
                  }),
                  VerticalDivider(thickness: 1),
                  Container(
                    width: 50,
                    child: AppTextField(
                      controller: totalParcelController,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      textFieldType: TextFieldType.PHONE,
                      decoration: InputDecoration(
                        counterText: '',
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.add, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    totalParcelController.text = (totalParcelController.text.toInt() + 1).toString();
                  }),
                ],
              ),
            ),
          ),
          16.height,
          Text(language.parcelType, style: boldTextStyle()),
          8.height,
          AppTextField(
            controller: parcelTypeCont,
            textFieldType: TextFieldType.OTHER,
            decoration: commonInputDecoration(),
            validator: (value) {
              if (value!.isEmpty) return language.fieldRequiredMsg;
              return null;
            },
          ),
          16.height,
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: parcelTypeList.map((item) {
              return Chip(
                backgroundColor: context.scaffoldBackgroundColor,
                label: Text(item.label!),
                elevation: 0,
                labelStyle: primaryTextStyle(color: Colors.grey),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  side: BorderSide(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                ),
              ).onTap(() {
                parcelTypeCont.text = item.label!;
                setState(() {});
              });
            }).toList(),
          ),
          16.height,
          Visibility(
            visible: appStore.isVehicleOrder != 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.select_vehicle, style: boldTextStyle()),
                8.height,
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedVehicle,
                  decoration: commonInputDecoration(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: primaryTextStyle(),
                  items: vehicleList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Row(
                        children: [
                          commonCachedNetworkImage(item.vehicleImage.validate(), height: 40, width: 40),
                          SizedBox(width: 16),
                          Text(item.title.validate(), style: primaryTextStyle()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedVehicle = value;
                    setState(() {});
                  },
                  validator: (value) {
                    if (selectedVehicle == null) return errorThisFieldRequired;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget createOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.pickupInformation, style: boldTextStyle()),
        16.height,
        Text(language.pickupLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickAddressCont,
          readOnly: true,
          textInputAction: TextInputAction.next,
          nextFocus: pickPhoneFocus,
          textFieldType: TextFieldType.MULTILINE,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (pickLat == null || pickLong == null) return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    pickAddressCont.text = address.placeAddress ?? "";
                    pickLat = address.latitude.toString();
                    pickLong = address.longitude.toString();
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        16.height,
        Text(language.pickupContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPhoneCont,
          focus: pickPhoneFocus,
          nextFocus: pickDesFocus,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: pickupCountryCode,
                    showCountryOnly: false,
                    dialogSize: Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      pickupCountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      pickupCountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        16.height,
        Text(language.pickupDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: pickDesCont,
          focusNode: pickDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.deliveryInformation, style: boldTextStyle()),
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverAddressCont,
          readOnly: true,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.MULTILINE,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    deliverAddressCont.text = address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    setState(() {});
                  },
                  isPickup: false,
                );
              },
            );
          },
        ),
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPhoneCont,
          textInputAction: TextInputAction.next,
          focus: deliverPhoneFocus,
          nextFocus: deliverDesFocus,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: deliverCountryCode,
                    showCountryOnly: false,
                    dialogSize: Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      deliverCountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      deliverCountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            // if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverDesCont,
          focusNode: deliverDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.packageInformation, style: boldTextStyle()),
        8.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.parcelType, style: primaryTextStyle()),
                  16.width,
                  Text(parcelTypeCont.text, style: primaryTextStyle(), maxLines: 3, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.weight, style: primaryTextStyle()),
                  16.width,
                  Text('${weightController.text} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}', style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.numberOfParcels, style: primaryTextStyle()),
                  16.width,
                  Text('${totalParcelController.text}', style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        16.height,
        Text(language.pickupLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickAddressCont.text, style: primaryTextStyle()),
              8.height.visible(pickPhoneCont.text.isNotEmpty),
              Text('$pickupCountryCode ${pickPhoneCont.text.trim()}', style: secondaryTextStyle()).visible(pickPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        16.height,
        Text(language.deliveryLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deliverAddressCont.text, style: primaryTextStyle()),
              8.height.visible(deliverPhoneCont.text.isNotEmpty),
              Text('$deliverCountryCode ${deliverPhoneCont.text.trim()}', style: secondaryTextStyle()).visible(deliverPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        Divider(height: 30),
        OrderSummeryWidget(extraChargesList: extraChargeList, totalDistance: totalDistance, totalWeight: weightController.text.toDouble(), distanceCharge: distanceCharge, weightCharge: weightCharge, totalAmount: totalAmount),
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
                            : borderColor,
                  ),
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
                DropdownMenuItem(value: PAYMENT_ON_PICKUP, child: Text(language.pickupLocation, style: primaryTextStyle(), maxLines: 1)),
                DropdownMenuItem(value: PAYMENT_ON_DELIVERY, child: Text(language.deliveryLocation, style: primaryTextStyle(), maxLines: 1)),
              ],
              onChanged: (value) {
                paymentCollectFrom = value!;
                setState(() {});
              },
            ).expand(),
          ],
        ).visible(isSelected == 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          await showInDialog(
            context,
            contentPadding: EdgeInsets.all(16),
            builder: (p0) {
              return CreateOrderConfirmationDialog(
                onCancel: () {
                  finish(context);
                  finish(context);
                },
                onSuccess: () {
                  finish(context);
                  createOrderApiCall(ORDER_DRAFT);
                },
                message: language.saveDraftConfirmationMsg,
                primaryText: language.saveDraft,
              );
            },
          );
          return false;
        } else {
          selectedTabIndex--;
          setState(() {});
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(language.createOrder)),
        body: BodyCornerWidget(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          return Container(
                            alignment: Alignment.center,
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: selectedTabIndex >= index ? colorPrimary : (appStore.isDarkMode ? scaffoldSecondaryDark : borderColor),
                              shape: BoxShape.circle,
                            ),
                            child: Text('${index + 1}', style: primaryTextStyle(color: selectedTabIndex >= index ? Colors.white : null)),
                          );
                        }).toList(),
                      ),
                      30.height,
                      if (selectedTabIndex == 0) createOrderWidget1(),
                      if (selectedTabIndex == 1) createOrderWidget2(),
                      if (selectedTabIndex == 2) createOrderWidget3(),
                      if (selectedTabIndex == 3) createOrderWidget4(),
                    ],
                  ),
                ),
              ),
              Observer(
                builder: (context) => loaderWidget().visible(appStore.isLoading),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          color: context.scaffoldBackgroundColor,
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  selectedTabIndex--;
                  setState(() {});
                }).paddingRight(16).expand(),
              commonButton(selectedTabIndex != 3 ? language.next : language.createOrder, () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (selectedTabIndex != 3) {
                  if (_formKey.currentState!.validate()) {
                    Duration difference = Duration();
                    Duration differenceCurrentTime = Duration();
                    if (!isDeliverNow) {
                      pickFromDateTime = pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
                      pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
                      deliverFromDateTime = deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
                      deliverToDateTime = deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
                      difference = pickFromDateTime!.difference(deliverFromDateTime!);
                      differenceCurrentTime = DateTime.now().difference(pickFromDateTime!);
                    }
                    if (differenceCurrentTime.inMinutes > 0) return toast(language.pickupCurrentValidationMsg);
                    if (difference.inMinutes > 0) return toast(language.pickupDeliverValidationMsg);
                    selectedTabIndex++;
                    if (selectedTabIndex == 3) {
                      getTotalAmount();
                    }
                    setState(() {});
                  }
                } else {
                  showConfirmDialog(
                    context,
                    language.createOrderConfirmationMsg,
                    positiveText: language.yes,
                    negativeText: language.no,
                    onAccept: () {
                      createOrderApiCall(ORDER_CREATED);
                    },
                  );
                }
              }).expand()
            ],
          ),
        ),
      ),
    );
  }
}
