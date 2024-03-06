import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;
  bool isLoading = false;
  String? imageURL;

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

  String? userName;
  String? userSurname;
  String? userEmail;
  String? userPhone;
  String? userAddress;
  String? userIC;
  String? userLicense;
  String? userCity;
  String? userPostcode;
  String? userState;
  String? selectedState;
  String? imageinDB;
  int? matchingIndex;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode idFocus = FocusNode();
  FocusNode licenseFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode postcodeFocus = FocusNode();

  XFile? imageProfile;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      init();
    });
  }

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var obtainedID = sharedPreferences.getString('id');

    final url = Uri.parse( mBaseUrl +'driverDetail/' + obtainedID!);

    final response = await http.get(
      url,
      headers: headers, // Encode the request body to JSON
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        imageinDB = responseData['user_image'];
        userName = responseData['user_name'];
        userSurname = responseData['user_surname'];
        userEmail = responseData['user_email'];
        userPhone = responseData['user_phone'];
        userAddress = responseData['user_address'];
        userIC = responseData['user_ic'];
        userLicense = responseData['user_license'];
        userCity = responseData['user_city'];
        userPostcode = responseData['user_postcode'];
        userState = responseData['user_state'];

        idController.text = userIC!;
        licenseController.text = userLicense!;
        emailController.text = userEmail!;
        usernameController.text = userSurname!;
        nameController.text = userName!;
        contactNumberController.text = userPhone!;
        addressController.text = userAddress!;
        cityController.text = userCity!;
        postcodeController.text = userPostcode!;

        if(imageinDB == null){
          imageURL  = DOMAIN_URL + "/images/profile.png";
        }else{
          imageURL  = DOMAIN_URL + "/drivers/" + imageinDB!;
        }


        // Loop through the malaysiaStates list to find a match
        for (int i = 0; i < malaysiaStates.length; i++) {
          if (malaysiaStates[i] == userState) {
            // A match is found, store the index
            matchingIndex = i;

            selectedState = malaysiaStates[matchingIndex!];

            setState(() {
              isLoading = false;
            });

            break; // Exit the loop once a match is found
          }
        }
      } else {
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
    } else {
      // Handle HTTP request error
      Fluttertoast.showToast(
        msg: "Something Went Wrong",
        toastLength: Toast.LENGTH_SHORT, // Duration for which the toast message will be displayed
        gravity: ToastGravity.BOTTOM, // Position of the toast message
        timeInSecForIosWeb: 1, // Only for iOS and web
        backgroundColor: Colors.black.withOpacity(0.7), // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the text
      );
    }
  }

  Future<void> updateDriver(File? image,String phoneNumber, String name, String surname, String address, String email, String city, String state, String postcode) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var obtainedID = sharedPreferences.getString('id');

    var url = Uri.parse(mBaseUrl + 'updateDriver/' + obtainedID!);

    var request = http.MultipartRequest('POST', url);

    // Add image to the request as a file
    if (image != null) {
      request.files.add(await http.MultipartFile(
        'image',
        http.ByteStream(image.openRead()),
        await image.length(),
        filename: image.path.split('/').last,
      ));
    }
    // Add other profile data as fields
    request.fields['phone_number'] = phoneNumber;
    request.fields['name'] = name;
    request.fields['surname'] = surname;
    request.fields['address'] = address;
    request.fields['email'] = email;
    request.fields['city'] = city;
    request.fields['state'] = state;
    request.fields['postcode'] = postcode;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Profile Updated!",
            toastLength: Toast.LENGTH_SHORT,
            // Duration for which the toast message will be displayed
            gravity: ToastGravity.BOTTOM,
            // Position of the toast message
            timeInSecForIosWeb: 1,
            // Only for iOS and web
            backgroundColor: Colors.black.withOpacity(0.7),
            // Background color of the toast
            textColor: Colors.white,
            // Text color of the toast
            fontSize: 16.0, // Font size of the text
          );

          Navigator.pop(context);

      } else {
        print("Response Status Code: ${response.statusCode}");
        // Handle registration error
        if(response.statusCode == 413) {
          Fluttertoast.showToast(
            msg: "The image file exceeds the limit",
            toastLength: Toast.LENGTH_SHORT,
            // Duration for which the toast message will be displayed
            gravity: ToastGravity.BOTTOM,
            // Position of the toast message
            timeInSecForIosWeb: 1,
            // Only for iOS and web
            backgroundColor: Colors.black.withOpacity(0.7),
            // Background color of the toast
            textColor: Colors.white,
            // Text color of the toast
            fontSize: 16.0, // Font size of the text
          );
        }else{
          Fluttertoast.showToast(
            msg: "Something Went Wrong!",
            toastLength: Toast.LENGTH_SHORT,
            // Duration for which the toast message will be displayed
            gravity: ToastGravity.BOTTOM,
            // Position of the toast message
            timeInSecForIosWeb: 1,
            // Only for iOS and web
            backgroundColor: Colors.black.withOpacity(0.7),
            // Background color of the toast
            textColor: Colors.white,
            // Text color of the toast
            fontSize: 16.0, // Font size of the text
          );
        }
      }
    }catch (e) {
      // Handle exceptions
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        // ... (Toast configuration options)
      );
    }
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Image.file(File(imageProfile!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(100).center();
    } else {
        return commonCachedNetworkImage(
            imageURL, fit: BoxFit.cover, height: 100, width: 100)
            .cornerRadiusWithClipRRect(100)
            .center();
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
      backgroundColor: colorPrimary,
      body: Center(
        child: SpinKitWanderingCubes(
          color: Colors.white,
        ),
      ),
    ):Scaffold(
      appBar: AppBar(title: Text(language.editProfile)),
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
                    Stack(
                      children: [
                        profileImage(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: colorPrimary),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    16.height,
                    Text('IC No.', style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: idController,
                      textFieldType: TextFieldType.NUMBER,
                      focus: idFocus,
                      nextFocus: licenseFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast('You cannot change your IC number.');
                      },
                    ),
                    16.height,
                    Text('License No.', style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: licenseController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: licenseFocus,
                      nextFocus: emailFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast('You cannot change your license number.');
                      },
                    ),
                    16.height,
                    Text(language.email, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: usernameFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                    Text(language.username, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: usernameController,
                      textFieldType: TextFieldType.USERNAME,
                      focus: usernameFocus,
                      nextFocus: nameFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: nameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      nextFocus: contactFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                    ),
                    16.height,
                    Text(language.contactNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: contactNumberController,
                      textFieldType: TextFieldType.PHONE,
                      focus: contactFocus,
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
                                enabled: false,
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
                      //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    16.height,
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: addressController,
                      textFieldType: TextFieldType.MULTILINE,
                      focus: addressFocus,
                      nextFocus: cityFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                    Text('City', style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: cityController,
                      textFieldType: TextFieldType.OTHER,
                      focus: cityFocus,
                      nextFocus: postcodeFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                    ),
                    16.height,
                    Text('Postcode', style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: postcodeController,
                      textFieldType: TextFieldType.NUMBER,
                      focus: postcodeFocus,
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
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          final phoneNumber = contactNumberController.text;
          final name = nameController.text;
          final surname = usernameController.text;
          final address = addressController.text;
          final email = emailController.text;
          final city = cityController.text;
          final state = selectedState!;
          final postcode = postcodeController.text;

            updateDriver(imageProfile != null ? File(imageProfile!.path) : null,phoneNumber, name, surname, address, email, city, state, postcode);


        }),
      ),
    );
  }
}
