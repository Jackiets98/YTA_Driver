import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:yes_tracker/user/screens/TrackerDashboard.dart';
import '../../main/screens/ForgotPasswordScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;

  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token;

  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();


  Future<void> loginDriver(String phoneNumber, String password) async {
    token = await _firebaseMessaging.getToken();
    final url = Uri.parse(mBaseUrl + 'driverLogin');

  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (isAndroid) {
    androidInfo = await deviceInfo.androidInfo;
  } else if (isIOS) {
    iosInfo = await deviceInfo.iosInfo;
    print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
  } else {
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    print('Running on ${webBrowserInfo.userAgent}');
  }

  final Map<String, String> requestBody = {
    'phone_number': phoneNumber,
    'password': password,
    'deviceID': isAndroid ? (androidInfo?.id ?? 'defaultAndroidID') : (iosInfo?.identifierForVendor ?? 'defaultIOSID'),
    'device_token': token!,
  };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody), // Encode the request body to JSON
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true) {
        Fluttertoast.showToast(
          msg: "Welcome Back!",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );

        print(body['user_id']);

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('id', body['user_id']);
        sharedPreferences.setString('name', body['user_name']);
        sharedPreferences.setString('androidID', body['user_device']);

        print('deviceID : ${body['user_device']}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TrackerDashboard()),
        );
      } else if(body['success'] == 'disabled') {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "Your account has been Deactivated.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      } else if(body['success'] == 'noPhone') {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "Please enter Phone Number.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      } else if(body['success'] == 'noPassword') {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "Please enter Password.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      } else if(body['success'] == 'noCredentials') {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "Please enter Phone Number and Password to log in.",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      } else {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "You have entered the wrong Credentials",
          toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
          gravity: ToastGravity.BOTTOM, // Position of the toast message
          timeInSecForIosWeb: 1, // Only for iOS and web
          backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
          textColor: Colors.white, // Text color of the toast
          fontSize: 16.0, // Font size of the text
        );
      }
    } else {
      print(response.statusCode);
      // Handle HTTP request error
      Fluttertoast.showToast(
        msg: "There is an error occurred.",
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
  void initState() {
    super.initState();
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: context.height() * 0.25,
                child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(height: 150, width: 350, alignment: Alignment.center, child: Image.asset('assets/logo.png')),
                      ],
                    ),
              ),
              Container(
                width: context.width(),
                padding: EdgeInsets.only(left: 24, right: 24),
                decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        24.height,
                        Text(language.signIn, style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text(language.signInWithYourCredential, style: secondaryTextStyle(size: 16)),
                        16.height,
                        Text('Phone Number', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: phoneController,
                          textFieldType: TextFieldType.PHONE,
                          focus: phoneFocus,
                          nextFocus: passFocus,
                          decoration: commonInputDecoration(
                            prefixIcon: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountryCodePicker(
                                    initialSelection: countryCode,
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
                                      countryCode = c!.dialCode!;
                                    },
                                    onChanged: (c) {
                                      countryCode = c.dialCode!;
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
                        Text(language.password, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: passController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorMinimumPasswordLength: language.passwordInvalid,
                        ),
                        SizedBox(height: 50,),
                        commonButton(
                          language.signIn,
                          () {
                            final phoneNumber = phoneController.text;
                            final password = passController.text;

                            loginDriver(phoneNumber, password);
                          },
                          width: context.width(),
                        ),
                        6.height,
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: Text(language.forgotPasswordQue, style: primaryTextStyle(color: colorPrimary, size: 12)).onTap(() {
                        //     ForgotPasswordScreen().launch(context);
                        //   }),
                        // ),
                        SizedBox(height: 200),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(language.doNotHaveAccount, style: primaryTextStyle()),
                        //     4.width,
                        //     Text(language.signUp, style: boldTextStyle(color: colorPrimary)).onTap(() {
                        //       RegisterScreen().launch(context, duration: Duration(milliseconds: 500), pageRouteAnimation: PageRouteAnimation.Slide);
                        //     }),
                        //   ],
                        // ),
                        // 16.height,
                      ],
                    ),
                  ),
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
