import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/services/AuthSertvices.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../user/components/CancelOrderDialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../components/OTPDialog.dart';

class ReceivedScreenOrderScreen extends StatefulWidget {
  final OrderData? orderData;
  final bool isShowPayment;

  ReceivedScreenOrderScreen({this.orderData, this.isShowPayment = false});

  @override
  ReceivedScreenOrderScreenState createState() => ReceivedScreenOrderScreenState();
}

class ReceivedScreenOrderScreenState extends State<ReceivedScreenOrderScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GlobalKey<SfSignaturePadState> signaturePicUPPadKey = GlobalKey();
  GlobalKey<SfSignaturePadState> signatureDeliveryPadKey = GlobalKey();

  ScreenshotController pickupScreenshotController = ScreenshotController();
  ScreenshotController deliveryScreenshotController = ScreenshotController();

  TextEditingController picUpController = TextEditingController();
  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  XFile? imageProfile;
  int val = 0;

  File? imageSignature;
  File? deliverySignature;
  bool mIsUpdate = false;
  int groupVal = 0;
  String? reason;
  bool mIsCheck = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    mIsUpdate = widget.orderData != null;
    if (mIsUpdate) {
      picUpController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.orderData!.pickupDatetime.validate().isEmpty ? DateTime.now().toString() : widget.orderData!.pickupDatetime.validate()));
      reasonController.text = widget.orderData!.reason.validate();
      reason = widget.orderData!.reason.validate();
      log(picUpController);
    }

    if (widget.orderData!.status == ORDER_DEPARTED) deliveryDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  Future<File> saveSignature(ScreenshotController screenshotController) async {
    final image = await screenshotController.capture(delay: Duration(milliseconds: 10));
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    if (image != null) {
      file.writeAsBytesSync(image);
    }
    return file;
  }

  saveDelivery() async {
    // appStore.setLoading(true);

  }

  Future<void> selectPic() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                color: colorPrimary,
                text: language.imagePickToCamera,
                textStyle: primaryTextStyle(color: white),
                onTap: () {
                  val = 1;
                  getImage();
                  finish(context);
                },
              ),
              16.height,
              AppButton(
                color: colorPrimary,
                text: language.imagePicToGallery,
                textStyle: primaryTextStyle(color: white),
                onTap: () {
                  val = 2;
                  getImage();
                  finish(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage() async {
    if (val == 1) {
      imageProfile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
    } else {
      imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderData!.status == ORDER_DEPARTED ? language.orderDeliver : language.orderPickup),
        leading: IconButton(
          onPressed: () {
            finish(context, false);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Observer(builder: (context) {
        return Form(
          key: formKey,
          child: Stack(
            children: [
              BodyCornerWidget(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.orderData!.paymentId == null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            color: Colors.red.withOpacity(0.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(defaultRadius),
                                    bottomLeft: Radius.circular(defaultRadius),
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.info_outlined),
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.info, style: boldTextStyle()),
                                  4.height,
                                  widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY
                                      ? Text(language.paymentCollectFromDelivery, style: secondaryTextStyle())
                                      : Text(language.paymentCollectFromPickup, style: secondaryTextStyle()),
                                ],
                              ).paddingAll(8),
                            ],
                          ),
                        ),
                      16.height,
                      Text('${language.order} ${language.pickupDatetime}', style: boldTextStyle()),
                      8.height,
                      AppTextField(
                        readOnly: true,
                        textFieldType: TextFieldType.OTHER,
                        controller: picUpController,
                        decoration: commonInputDecoration(),
                      ),
                      16.height,
                      if (widget.orderData!.status == ORDER_DEPARTED)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.deliveryDatetime, style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              readOnly: true,
                              textFieldType: TextFieldType.PHONE,
                              controller: deliveryDateController,
                              decoration: commonInputDecoration(),
                            ),
                          ],
                        ),
                      16.height,
                      Text(language.userSignature, style: boldTextStyle()),
                      8.height,
                      // widget.orderData!.pickupConfirmByClient == 1 || widget.orderData!.status == ORDER_DEPARTED
                      //     ? commonCachedNetworkImage(widget.orderData!.pickupTimeSignature, fit: BoxFit.cover, height: 150, width: context.width())
                      //     :
                      Container(
                              height: 150,
                              width: context.width(),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.15)),
                              child: Screenshot(
                                controller: pickupScreenshotController,
                                child: SfSignaturePad(
                                  key: signaturePicUPPadKey,
                                  minimumStrokeWidth: 1,
                                  maximumStrokeWidth: 3,
                                  strokeColor: colorPrimary,
                                ),
                              ),
                            ),
                      if (widget.orderData!.pickupConfirmByClient != 1)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              8.width,
                              TextButton(
                                child: Text(language.clear, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                                onPressed: () async {
                                  signaturePicUPPadKey.currentState!.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      Text(language.deliveryTimeSignature, style: boldTextStyle()).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_DELIVERED),
                      8.height.visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_DELIVERED),
                      if (widget.orderData!.status == ORDER_DEPARTED)
                        Container(
                          height: 150,
                          width: context.width(),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.15)),
                          child: Screenshot(
                            controller: deliveryScreenshotController,
                            child: SfSignaturePad(
                              key: signatureDeliveryPadKey,
                              minimumStrokeWidth: 1,
                              maximumStrokeWidth: 3,
                              strokeColor: colorPrimary,
                            ),
                          ),
                        ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_DELIVERED),
                      if (widget.orderData!.status == ORDER_DEPARTED)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              8.width,
                              TextButton(
                                child: Text(language.clear, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                                onPressed: () async {
                                  signatureDeliveryPadKey.currentState!.clear();
                                },
                              ),
                            ],
                          ),
                        ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_DELIVERED),
                      16.height,
                      CheckboxListTile(
                        value: mIsCheck,
                        activeColor: colorPrimary,
                        title: Text(widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY ? language.paymentCollectFrom : language.paymentCollectFromPickup, style: primaryTextStyle()),
                        onChanged: (val) {
                          mIsCheck = val!;
                          setState(() {});
                        },
                      ).visible(widget.isShowPayment),
                      16.height,
                      Row(
                        children: [
                          AppButton(
                            width: context.width(),
                            text: widget.orderData!.status == ORDER_DEPARTED ? language.confirmDelivery : language.confirmPickup,
                            textStyle: primaryTextStyle(color: white),
                            color: colorPrimary,
                            onTap: () async {
                              if (!mIsCheck && widget.orderData!.paymentId == null && widget.isShowPayment) {
                                return toast(language.pleaseConfirmPayment);
                              } else {

                              }
                            },
                          ).expand(),
                          if (widget.orderData!.status == ORDER_ACCEPTED && widget.orderData!.status == ORDER_ARRIVED) 16.width,
                          if (widget.orderData!.status == ORDER_ACCEPTED && widget.orderData!.status == ORDER_ARRIVED)
                            AppButton(
                              width: context.width(),
                              text: language.cancelOrder,
                              textStyle: primaryTextStyle(color: white),
                              elevation: 0,
                              color: Colors.red,
                              onTap: () async {
                                showInDialog(
                                  context,
                                  contentPadding: EdgeInsets.all(16),
                                  builder: (p0) {

                                  },
                                );
                              },
                            ).expand(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Observer(
                builder: (_) => loaderWidget().visible(appStore.isLoading),
              )
            ],
          ),
        );
      }),
    );
  }

  Future<void> saveOrderData() async {
    if (widget.orderData!.status == ORDER_DEPARTED) {
      if (deliveryDateController.text.isEmpty) {
        return toast(language.selectDeliveryTimeMsg);
      }
    }

    if (widget.orderData!.status == ORDER_ACCEPTED || widget.orderData!.status == ORDER_ARRIVED) {
      if (imageSignature == null) {
        imageSignature = await saveSignature(pickupScreenshotController);
        log(imageSignature!.path);
      }
    }
    if (widget.orderData!.status == ORDER_DEPARTED) {
      if (deliverySignature == null) {
        deliverySignature = await saveSignature(deliveryScreenshotController);
        log(deliverySignature!.path);
      }
    }

    if (widget.orderData!.paymentId == null && widget.orderData!.paymentCollectFrom == PAYMENT_ON_PICKUP && (widget.orderData!.status == ORDER_ACCEPTED || widget.orderData!.status == ORDER_ARRIVED)) {
      appStore.setLoading(true);
      await paymentConfirmDialog(widget.orderData!);
      appStore.setLoading(false);
    } else if (widget.orderData!.paymentId == null && widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY && widget.orderData!.status == ORDER_DEPARTED) {
      appStore.setLoading(true);
      await paymentConfirmDialog(widget.orderData!);
      appStore.setLoading(false);
    } else {
      showConfirmDialogCustom(
        context,
        primaryColor: colorPrimary,
        dialogType: DialogType.CONFIRMATION,
        title: orderTitle(widget.orderData!.status!),
        positiveText: language.yes,
        negativeText: language.no,
        onAccept: (c) async {
          saveDelivery();
        },
      );
    }
  }

  Future<void> paymentConfirmDialog(OrderData orderData) {
    return showConfirmDialogCustom(context, primaryColor: colorPrimary, dialogType: DialogType.CONFIRMATION, title: orderTitle(orderData.status!), positiveText: language.yes, negativeText: language.cancel, onAccept: (c) async {
      appStore.setLoading(true);
      Map req = {
        'order_id': orderData.id,
        'datetime': picUpController.text,
        'total_amount': orderData.totalAmount,
        'payment_type': PAYMENT_TYPE_CASH,
        'payment_status': PAYMENT_PAID,
      };
    }, onCancel: (v) {
      finish(context, false);
    });
  }
}
