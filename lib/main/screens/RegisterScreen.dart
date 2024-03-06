import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:yes_tracker/main/screens/LoginScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  final String? userType;
  static String tag = '/RegisterScreen';

  RegisterScreen({this.userType});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;

  // Define a list of Malaysia states
  List<String> malaysiaStates = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Penang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Wilayah Persekutuan Kuala Lumpur',
    'Wilayah Persekutuan Labuan',
    'Wilayah Persekutuan Putrajaya',
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode idFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode licenseFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode postcodeFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  bool isAcceptedTc = false;

  Future<void> registerDriver(String phoneNumber, String name, String surname, String ID, String license, String address, String email, String password, String city, String state, String postcode) async {

    var url = Uri.parse(mBaseUrl + 'createDriver');

    final response = await http.post(
      url,
      body: {'phone_number': phoneNumber,'name': name, 'surname': surname, 'ic_no': ID, 'license': license, 'address': address, 'email': email, 'password': password, 'city': city, 'state': state, 'postcode': postcode},
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Account Created",
        toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
        gravity: ToastGravity.BOTTOM, // Position of the toast message
        timeInSecForIosWeb: 1, // Only for iOS and web
        backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the text
      );

      LoginScreen().launch(context);
    } else {
      // Handle registration error
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

  Future<void> init() async {
    log(widget.userType);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    String selectedState = malaysiaStates[0];
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(height: 150, width: 350, alignment: Alignment.center, child: Image.asset('assets/logo.png')),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 40, left: 16),
                    child: Icon(Icons.arrow_back, color: Colors.white).onTap(() {
                      finish(context);
                    }),
                  ),
                ],
              ).withHeight(
                context.height() * 0.25,
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
                      children: [
                        30.height,
                        Text(language.signUp, style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text(language.signUpWithYourCredential, style: secondaryTextStyle(size: 16)),
                        30.height,
                        Text(language.name, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: nameController,
                          textFieldType: TextFieldType.NAME,
                          focus: nameFocus,
                          nextFocus: userNameFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                        ),
                        16.height,
                        Text('Surname', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: userNameController,
                          textFieldType: TextFieldType.USERNAME,
                          focus: userNameFocus,
                          nextFocus: idFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorInvalidUsername: language.usernameInvalid,
                        ),
                        16.height,
                        Text('IC No.', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: idController,
                          textFieldType: TextFieldType.NUMBER,
                          focus: idFocus,
                          nextFocus: licenseFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                        ),
                        16.height,
                        Text('License No.', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: licenseController,
                          textFieldType: TextFieldType.NUMBER,
                          focus: licenseFocus,
                          nextFocus: emailFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                        ),
                        16.height,
                        Text(language.email, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: phoneFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorInvalidEmail: language.emailInvalid,
                        ),
                        16.height,
                        Text(language.contactNumber, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: phoneController,
                          textFieldType: TextFieldType.PHONE,
                          focus: phoneFocus,
                          nextFocus: addressFocus,
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
                        Text('Address', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: addressController,
                          textFieldType: TextFieldType.OTHER,
                          focus: addressFocus,
                          nextFocus: cityFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorInvalidUsername: language.usernameInvalid,
                        ),
                        16.height,
                        Text('City', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: cityController,
                          textFieldType: TextFieldType.OTHER,
                          focus: cityFocus,
                          nextFocus: stateFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                        ),
                        16.height,
                        Text('State', style: primaryTextStyle()),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedState,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedState = newValue!;
                            });
                          },
                          items: malaysiaStates.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          decoration: commonInputDecoration(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a state';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            // Save the selected state value when the form is submitted.
                            selectedState = value!;
                          },
                        ),
                        16.height,
                        Text('Postcode', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: postcodeController,
                          textFieldType: TextFieldType.NUMBER,
                          focus: postcodeFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
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
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: colorPrimary,
                          title: RichTextWidget(
                            list: [
                              TextSpan(text: '${language.iAgreeToThe}', style: secondaryTextStyle()),
                              TextSpan(
                                text: language.termOfService,
                                style: boldTextStyle(color: colorPrimary, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    commonLaunchUrl(mTermAndCondition);
                                  },
                              ),
                              TextSpan(text: ' & ', style: secondaryTextStyle()),
                              TextSpan(
                                text: language.privacyPolicy,
                                style: boldTextStyle(color: colorPrimary, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    commonLaunchUrl(mPrivacyPolicy);
                                  },
                              ),
                            ],
                          ),
                          value: isAcceptedTc,
                          onChanged: (val) async {
                            isAcceptedTc = val!;
                            setState(() {});
                          },
                        ),
                        30.height,
                        commonButton(language.signUp, () async{
                          final phoneNumber = phoneController.text;
                          final name = nameController.text;
                          final surname = userNameController.text;
                          final ID = idController.text;
                          final license = licenseController.text;
                          final address = addressController.text;
                          final email = emailController.text;
                          final password = passController.text;
                          final city = cityController.text;
                          final state = stateController.text;
                          final postcode = postcodeController.text;

                          registerDriver(phoneNumber, name, surname, ID, license, address, email, password, city, state, postcode);
                          // LoginScreen().launch(context);
                        }, width: context.width()),
                        16.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(language.alreadyHaveAnAccount, style: primaryTextStyle()),
                            4.width,
                            Text(language.signIn, style: boldTextStyle(color: colorPrimary)).onTap(() {
                              finish(context);
                            }),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ).withHeight(context.height()),
    );
  }
}
