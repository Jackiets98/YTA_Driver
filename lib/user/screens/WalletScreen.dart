import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:yes_tracker/main/models/LoginResponse.dart';
import '../../main/screens/BankDetailScreen.dart';
import '../../main/utils/Colors.dart';
import '../../user/components/PaymentScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/WithDrawScreen.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/WalletListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';

class WalletScreen extends StatefulWidget {
  static String tag = '/WalletScreen';

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  TextEditingController amountCont = TextEditingController();

  UserBankAccount? userBankAccount;

  List<WalletModel> walletData = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = -1;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getBankDetail();
    getWalletData();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          // appStore.setLoading(true);
          currentPage++;
          setState(() {});
          getWalletData();
        }
      }
    });
  }

  getBankDetail() async {

  }

  getWalletData() async {
    // appStore.setLoading(true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        appStore.availableBal = totalAmount;
        finish(context,true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(language.wallet)),
        body: Stack(
          children: [
            BodyCornerWidget(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.availableBalance, style: primaryTextStyle(size: 16, color: white.withOpacity(0.7))),
                              6.height,
                              Text('${printAmount(totalAmount)}', style: boldTextStyle(size: 22, color: Colors.white)),
                            ],
                          ),
                          commonButton(language.addMoney, () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  insetPadding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(language.addMoney, style: boldTextStyle(size: 18)),
                                      Divider(),
                                      16.height,
                                      Text(language.amount, style: primaryTextStyle()),
                                      8.height,
                                      AppTextField(
                                        controller: amountCont,
                                        textFieldType: TextFieldType.PHONE,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: commonInputDecoration(),
                                      ),
                                      16.height,
                                      commonButton(
                                        language.add,
                                        () async {
                                          Navigator.pop(context);
                                          bool? res = await PaymentScreen(
                                            totalAmount: amountCont.text.toDouble(),
                                            isWallet: true,
                                          ).launch(context);
                                          if (res == true) {
                                            getWalletData();
                                          }
                                        },
                                        width: context.width(),
                                      ),
                                      16.height,
                                    ],
                                  ).paddingAll(16),
                                );
                              },
                            );
                          }, color:  context.cardColor, textColor: colorPrimary)
                        ],
                      ),
                    ),
                    16.height,
                    ListView.builder(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: walletData.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        WalletModel data = walletData[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(8),
                          decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(),backgroundColor: context.cardColor,shadowColor: appStore.isDarkMode ? Colors.transparent : null),
                          child: Row(
                            children: [
                              Container(
                                decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.withOpacity(0.2)),
                                padding: EdgeInsets.all(6),
                                child: Icon(data.type == CREDIT ? Icons.add : Icons.remove, color: colorPrimary),
                              ),
                              10.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transactionType(data.transactionType!), style: boldTextStyle(size: 16)),
                                    SizedBox(height: 8),
                                    Text(printDate(data.createdAt.validate()), style: secondaryTextStyle(size: 12)),
                                  ],
                                ),
                              ),
                              Text('${printAmount(data.amount)}', style: secondaryTextStyle(color:data.type == CREDIT? Colors.green:Colors.red))
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (totalAmount != 0)
                Expanded(
                  child: commonButton(
                    language.withdraw,
                    () {
                      if (userBankAccount != null)
                        WithDrawScreen(
                          onTap: () {
                            init();
                          },
                        ).launch(context);
                      else {
                        toast(language.bankNotFound);
                        BankDetailScreen(isWallet: true).launch(context);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
