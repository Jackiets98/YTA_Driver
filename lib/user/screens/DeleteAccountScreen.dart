import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import '../../main/utils/Constants.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  DeleteAccountScreenState createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> deleteAccount() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var obtainedID = sharedPreferences.getString('id');

    var url = Uri.parse(mBaseUrl + 'disableAccount/' + obtainedID!);

    final response = await http.post(
      url,
      body: {'status': '0'},
    );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Your account has been deactivated.",
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => LoginScreen()), (route) => false);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.deleteAccount, style: TextStyle(color: Colors.white))),
      body: Stack(
        children: [
          BodyCornerWidget(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.deleteAccountMsg1, style: primaryTextStyle()),
                  16.height,
                  Text(language.account, style: boldTextStyle()),
                  8.height,
                  Text(language.deleteAccountMsg2, style: primaryTextStyle()),
                  24.height,
                  commonButton(
                      language.deleteAccount,
                      () async => {
                            await showConfirmDialogCustom(
                              context,
                              title: language.deleteAccountConfirmMsg,
                              dialogType: DialogType.DELETE,
                              positiveText: language.yes,
                              negativeText: language.no,
                              onAccept: (c) async {
                                await deleteAccount();
                              },
                            ),
                          },
                      color: Colors.red),
                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return loaderWidget().visible(appStore.isLoading);
          }),
        ],
      ),
    );
  }
}
