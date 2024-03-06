import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import 'package:http/http.dart' as http;
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? userID;
  String? hashedPassword;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userID = sharedPreferences.getString('id');

    final url = Uri.parse(mBaseUrl + 'getPassword/' + userID!);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      hashedPassword = data['password'];

      // Now you have the hashed password in 'hashedPassword'
      print('Hashed Password: $hashedPassword');
    } else {
      // Handle HTTP error
    }
  }

  Future<void> submit() async {
    final bool passwordMatches = await BCrypt.checkpw(oldPassController.text.trim(), hashedPassword!);
    if (passwordMatches) {
      print('same');
      var url = Uri.parse(mBaseUrl + 'updatePassword/' + userID!);

      final response = await http.post(
        url,
        body: {'password': newPassController.text.trim()},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Password Updated!",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );

        Navigator.pop(context);
      } else {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "There is an error occured.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Invalid Old Password.",
        toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
        gravity: ToastGravity.BOTTOM, // Position of the toast message
        timeInSecForIosWeb: 1, // Only for iOS and web
        backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the text
      );
    }


  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.changePassword)),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: BodyCornerWidget(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.oldPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: oldPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: oldPassFocus,
                      nextFocus: newPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                    ),
                    16.height,
                    Text(language.newPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: newPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: newPassFocus,
                      nextFocus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                    ),
                    16.height,
                    Text(language.confirmPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: confirmPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                      validator: (val) {
                        if (val!.isEmpty) return language.fieldRequiredMsg;
                        if (val != newPassController.text) return language.passwordNotMatch;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          if (formKey.currentState!.validate()) {
            submit();
          }
        }),
      ),
    );
  }
}
