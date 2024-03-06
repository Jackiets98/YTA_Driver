import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/PaymentGatewayListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/StripePayModel.dart';

class PaymentScreen extends StatefulWidget {
  static String tag = '/PaymentScreen';
  final num totalAmount;
  final int? orderId;
  final bool? isWallet;

  PaymentScreen({required this.totalAmount, this.orderId, this.isWallet = false});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String? razorKey,
      stripPaymentKey,
      stripPaymentPublishKey,
      flutterWavePublicKey,
      flutterWaveSecretKey,
      flutterWaveEncryptionKey,
      payStackPublicKey,
      payPalTokenizationKey,
      mercadoPagoPublicKey,
      mercadoPagoAccessToken,
      payTabsProfileId,
      payTabsServerKey,
      payTabsClientKey,
      paytmMerchantId,
      paytmMerchantKey,
      myFatoorahToken;
  List<PaymentGatewayData> paymentGatewayList = [];
  String? selectedPaymentType;
  bool isTestType = true;



  bool isDisabled = false;

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }


  /// Get Payment Gateway Api Call
  Future<void> paymentListApiCall() async {
    // appStore.setLoading(true);
  }

  /// Save Payment
  Future<void> savePaymentApiCall({String? paymentType, String? txnId, String? paymentStatus = PAYMENT_PENDING, Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": widget.orderId.toString(),
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": widget.totalAmount.toString(),
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    // appStore.setLoading(true);

  }

  /// Razor Pay
  void razorPayPayment() async {
    var options = {
      'key': razorKey.validate(),
      'amount': (widget.totalAmount * 100).toInt(),
      'theme.color': '#5957b0',
      'name': mAppName,
      'description': 'On Demand Local Delivery System',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': getStringAsync(USER_CONTACT_NUMBER), 'email': getStringAsync(USER_EMAIL)},
      'external': {
        'wallets': ['paytm']
      }
    };

  }



  payStackUpdateStatus(String? reference, String message) {
    payStackShowMessage(message, const Duration(seconds: 7));
  }

  void payStackShowMessage(String message, [Duration duration = const Duration(seconds: 4)]) {
    toast(message);
    log(message);
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }


  Future<void> paymentConfirm() async {
    Map req = {
      "user_id": getIntAsync(USER_ID),
      "type": "credit",
      "amount": widget.totalAmount,
      "transaction_type": "topup",
      "currency": appStore.currencyCode,
    };
    appStore.isLoading = true;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.payment)),
      body: BodyCornerWidget(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              paymentGatewayList.isNotEmpty
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.paymentMethod, style: boldTextStyle()),
                              16.height,
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: paymentGatewayList.map((mData) {
                                  return GestureDetector(
                                    child: Container(
                                      width: (context.width() - 50) * 0.5,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      alignment: Alignment.center,
                                      decoration: boxDecorationWithRoundedCorners(
                                        backgroundColor: context.cardColor,
                                        borderRadius: BorderRadius.circular(defaultRadius),
                                        border: Border.all(
                                            color: mData.type == selectedPaymentType
                                                ? colorPrimary
                                                : appStore.isDarkMode
                                                    ? Colors.transparent
                                                    : borderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          commonCachedNetworkImage('${mData.gatewayLogo}', width: 40, height: 40),
                                          12.width,
                                          Text('${mData.title}', style: primaryTextStyle(), maxLines: 2).expand(),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      selectedPaymentType = mData.type;
                                      isTestType = mData.isTest == 1;
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: commonButton(language.payNow, () {

                          }, width: context.width())
                              .paddingAll(16),
                        ),
                      ],
                    )
                  : !appStore.isLoading
                      ? emptyWidget()
                      : SizedBox(),
              loaderWidget().visible(appStore.isLoading),
            ],
          );
        }),
      ),
    );
  }
}
