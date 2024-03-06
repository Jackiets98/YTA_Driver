import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/models/WithDrawListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';

class WithDrawScreen extends StatefulWidget {
  final Function() onTap;

  WithDrawScreen({required this.onTap});

  @override
  WithDrawScreenState createState() => WithDrawScreenState();
}

class WithDrawScreenState extends State<WithDrawScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  TextEditingController addMoneyController = TextEditingController();

  int currentPage = 1;
  int totalPage = 1;

  List<WithDrawModel> withDrawData = [];

  num totalAmount = 0;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          // appStore.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {

  }

  Future<void> withDrawRequest({int? userId, int? amount}) async {
    appStore.setLoading(true);
    Map req = {
      "user_id": appStore.uid,
      "currency": appStore.currencyCode.toLowerCase(),
      "amount": amount,
      "status": REQUESTED,
    };
  }

  String printStatus(String status) {
    String text = "";
    if (status == DECLINE) {
      text = language.declined;
    } else if (status == REQUESTED) {
      text = language.requested;
    } else if (status == APPROVED) {
      text = language.approved;
    }
    return text;
  }

  Color withdrawStatusColor(String status){
    Color color = colorPrimary;
    if (status == DECLINE) {
      color = Colors.red;
    } else if (status == REQUESTED) {
      color = colorPrimary;
    } else if (status == APPROVED) {
      color = Colors.green;
    }
    return color;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.withdraw, style: boldTextStyle(color: Colors.white)),
      ),
      body: Observer(builder: (context) {
        return Form(
          key: formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(language.availableBalance, style: secondaryTextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            Text('${printAmount(totalAmount)}', style: boldTextStyle(size: 22, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(language.withdrawHistory, style: boldTextStyle(size: 18)),
                    SizedBox(height: 16),
                    ListView.builder(
                      itemCount: withDrawData.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        WithDrawModel data = withDrawData[index];

                        return Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(printStatus(data.status!), style: boldTextStyle(color: withdrawStatusColor(data.status!))),
                                    SizedBox(height: 8),
                                    Text(printDate(data.createdAt!), style: secondaryTextStyle()),
                                  ],
                                ),
                              ),
                              Text('${printAmount(data.amount!.toDouble())}', style: primaryTextStyle()),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              ),
              !appStore.isLoading && withDrawData.isEmpty ? emptyWidget() : SizedBox(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Visibility(
        visible: totalAmount > 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: commonButton(
            language.withdraw,
                () {
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
                          controller: addMoneyController,
                          textFieldType: TextFieldType.PHONE,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (a) {
                            log(a);
                            if (a.toInt() >= totalAmount) {
                              addMoneyController.text = totalAmount.toString();
                            }
                          },
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        commonButton(
                          language.withdraw,
                              () async {
                            if (addMoneyController.text.isNotEmpty) {
                              await withDrawRequest(amount: int.parse(addMoneyController.text));
                            } else {
                              toast(language.addAmount);
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
            },
          ),
        ),
      ),
    );
  }
}
