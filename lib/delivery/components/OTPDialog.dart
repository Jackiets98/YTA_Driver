
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:yes_tracker/main/services/AuthSertvices.dart';
import '../../main.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart' hide OTPTextField;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';


class OTPDialog extends StatefulWidget {
  final String? phoneNumber;
  final Function()? onUpdate;
  final String? verificationId;

  OTPDialog({this.phoneNumber, this.onUpdate, this.verificationId});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  OtpFieldController otpController = OtpFieldController();
  String verId = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    verId = widget.verificationId.validate();
    setState(() {});
  }

  /*Future sendOTP() async {
    appStore.setLoading(true);
    log('********${widget.phoneNumber.validate()}');
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: widget.phoneNumber.validate(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        appStore.setLoading(false);
        toast(language.verificationCompleted);
      },
      verificationFailed: (FirebaseAuthException e) {
        appStore.setLoading(false);
        if (e.code == 'invalid-phone-number') {
          toast(language.phoneNumberInvalid);
          throw language.phoneNumberInvalid;
        } else {
          toast(e.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        appStore.setLoading(false);
        toast(language.codeSent);
        verId = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        appStore.setLoading(false);
      },
    );
  }*/

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.message, color: colorPrimary, size: 50),
            16.height,
            Text(language.otpVerification, style: boldTextStyle(size: 18)),
            16.height,
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(language.enterTheCodeSendTo, style: secondaryTextStyle(size: 16)),
                4.width,
                Text(widget.phoneNumber.validate(), style: boldTextStyle()),
              ],
            ),
            30.height,
            OTPTextField(
              controller: otpController,
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 35,
              style: primaryTextStyle(),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              onChanged: (s) {
                //
              },
              onCompleted: (pin) async {

              },
            ),
            30.height,
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(language.didNotReceiveTheCode, style: secondaryTextStyle(size: 16)),
                4.width,
                Text(language.resend, style: boldTextStyle(color: colorPrimary)).onTap(() {

                }),
              ],
            ),
          ],
        ),
        Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
      ],
    );
  }
}
