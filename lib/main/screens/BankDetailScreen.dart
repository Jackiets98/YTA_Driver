import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../models/LoginResponse.dart';
import '../network/NetworkUtils.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';

class BankDetailScreen extends StatefulWidget {
  final bool? isWallet;

  BankDetailScreen({this.isWallet = false});

  @override
  _BankDetailScreenState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameCon = TextEditingController();
  TextEditingController accNumberCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  TextEditingController ifscCCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getBankDetail();
  }

  getBankDetail() async {
    // appStore.setLoading(true);
  }

  saveBankDetail() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(language.bankDetails)),
            body: BodyCornerWidget(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(12),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          16.height,
                          AppTextField(
                            isValidationRequired: true,
                            controller: bankNameCon,
                            textFieldType: TextFieldType.NAME,
                            decoration: commonInputDecoration(hintText: language.bankName),
                          ),
                          16.height,
                          AppTextField(
                            isValidationRequired: true,
                            controller: accNumberCon,
                            textFieldType: TextFieldType.PHONE,
                            decoration: commonInputDecoration(hintText: language.accountNumber),
                          ),
                          16.height,
                          AppTextField(
                            isValidationRequired: true,
                            controller: nameCon,
                            textFieldType: TextFieldType.NAME,
                            decoration: commonInputDecoration(hintText: language.nameAsPerBank),
                          ),
                          16.height,
                          AppTextField(
                            isValidationRequired: true,
                            controller: ifscCCon,
                            textFieldType: TextFieldType.NAME,
                            decoration: commonInputDecoration(hintText: language.ifscCode),
                          ),
                          30.height,
                        ],
                      ),
                    ),
                  ),
                  loaderWidget().visible(appStore.isLoading)
                ],
              ),
            ),
            bottomNavigationBar: AppButton(
                color: colorPrimary,
                textColor: Colors.white,
                text: language.save,
                onTap: () {
                  saveBankDetail();
                }).paddingAll(16),
          );
        }
    );
  }
}
