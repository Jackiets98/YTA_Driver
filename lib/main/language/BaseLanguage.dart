import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get language;

  String get confirmation;

  String get cancel;

  String get create;

  String get filter;

  String get reset;

  String get status;

  String get date;

  String get from;

  String get applyFilter;

  String get to;

  String get toDateValidationMsg;

  String get payment;

  String get paymentMethod;

  String get payNow;

  String get pleaseSelectCity;

  String get selectRegion;

  String get country;

  String get city;

  String get logoutConfirmationMsg;

  String get yes;

  String get pickedAt;

  String get deliveredAt;

  String get trackOrder;

  String get deliveryNow;

  String get schedule;

  String get pickTime;

  String get endTimeValidationMsg;

  String get deliverTime;

  String get weight;

  String get parcelType;

  String get pickupInformation;

  String get address;

  String get contactNumber;

  String get description;

  String get deliveryInformation;

  String get packageInformation;

  String get pickup;

  String get delivery;

  String get deliveryCharge;

  String get distanceCharge;

  String get weightCharge;

  String get extraCharges;

  String get total;

  String get cash;

  String get online;

  String get paymentCollectFrom;

  String get saveDraftConfirmationMsg;

  String get saveDraft;

  String get createOrder;

  String get previous;

  String get pickupCurrentValidationMsg;

  String get pickupDeliverValidationMsg;

  String get createOrderConfirmationMsg;

  String get draftOrder;

  String get orderDetails;

  String get distance;

  String get parcelDetails;

  String get aboutDeliveryMan;

  String get aboutUser;

  String get returnOrder;

  String get cancelOrder;

  String get lblReturn;

  String get changePassword;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordNotMatch;

  String get saveChanges;

  String get profileUpdateMsg;

  String get editProfile;

  String get notChangeEmail;

  String get username;

  String get notChangeUsername;

  String get forgotPassword;

  String get email;

  String get submit;

  String get userNotApproveMsg;

  String get signInAccount;

  String get signInWithYourCredential;

  String get password;

  String get forgotPasswordQue;

  String get signIn;

  String get or;

  String get continueWithGoogle;

  String get doNotHaveAccount;

  String get signUp;

  String get name;

  String get notification;

  String get selectUsertypeMsg;

  String get createAnAccount;

  String get signUpWithYourCredential;

  String get userType;

  String get client;

  String get deliveryMan;

  String get alreadyHaveAnAccount;

  String get light;

  String get dark;

  String get systemDefault;

  String get theme;

  String get skip;

  String get getStarted;

  String get profile;

  String get trackOrderLocation;

  String get track;

  String get active;

  String get pickUp;

  String get departed;

  String get orderPickupSuccessfully;

  String get imagePickToCamera;

  String get imagePicToGallery;

  String get orderDeliver;

  String get orderPickup;

  String get info;

  String get paymentCollectFromDelivery;

  String get paymentCollectFromPickup;

  String get pickupDatetime;

  String get hour;

  String get deliveryDatetime;

  String get pickupTimeSignature;

  String get save;

  String get clear;

  String get deliveryTimeSignature;

  String get reason;

  String get pickupDelivery;

  String get selectPickupTimeMsg;

  String get selectDeliveryTimeMsg;

  String get selectPickupSignMsg;

  String get selectDeliverySignMsg;

  String get selectReasonMsg;

  String get orderCancelledSuccessfully;

  String get collectPaymentConfirmationMsg;

  String get trackingOrder;

  String get assign;

  String get pickedUp;

  String get arrived;

  String get completed;

  String get cancelled;

  String get allowLocationPermission;

  String get walkThrough1Title;

  String get walkThrough2Title;

  String get walkThrough3Title;

  String get walkThrough1Subtitle;

  String get walkThrough2Subtitle;

  String get walkThrough3Subtitle;

  String get order;

  String get account;

  String get drafts;

  String get aboutUs;

  String get helpAndSupport;

  String get logout;

  String get changeLocation;

  String get selectCity;

  String get next;

  String get fieldRequiredMsg;

  String get emailInvalid;

  String get passwordInvalid;

  String get usernameInvalid;

  String get writeReasonHere;

  String get areYouSureWantToArrive;

  String get note;

  String get courierWillPickupAt;

  String get courierWillDeliverAt;

  String get confirmDelivery;

  String get orderAssignConfirmation;

  String get orderPickupConfirmation;

  String get orderDepartedConfirmation;

  String get orderCreateConfirmation;

  String get orderCompleteConfirmation;

  String get orderCancelConfirmation;

  String get id;

  String get contactNumberValidation;

  String get rememberMe;

  String get becomeADeliveryBoy;

  String get orderHistory;

  String get no;

  String get confirmPickup;

  String get version;

  String get contactUs;

  String get purchase;

  String get privacyPolicy;

  String get termAndCondition;

  String get notifyUser;

  String get userSignature;

  String get notifications;

  String get contactLength;

  String get pickupLocation;

  String get deliveryLocation;

  String get myOrders;

  String get paymentType;

  String get orderId;

  String get createdAt;

  String get viewHistory;

  String get paymentDetails;

  String get paymentStatus;

  String get cancelledReason;

  String get returnReason;

  String get pleaseConfirmPayment;

  String get picked;

  String get at;

  String get delivered;

  String get yourLocation;

  String get lastUpdateAt;

  String get uploadFileConfirmationMsg;

  String get verifyDocument;

  String get selectDocument;

  String get addDocument;

  String get deleteMessage;

  String get writeAMessage;

  String get pending;

  String get failed;

  String get paid;

  String get onPickup;

  String get onDelivery;

  String get stripe;

  String get razorpay;

  String get payStack;

  String get flutterWave;

  String get deliveryContactNumber;

  String get deliveryDescription;

  String get pickupContactNumber;

  String get pickupDescription;

  String get success;

  String get paypal;

  String get payTabs;

  String get mercadoPago;

  String get paytm;

  String get myFatoorah;

  String get demoMsg;

  String get verificationCompleted;

  String get codeSent;

  String get otpVerification;

  String get enterTheCodeSendTo;

  String get invalidVerificationCode;

  String get didNotReceiveTheCode;

  String get resend;

  String get numberOfParcels;

  String get verified;

  String get invoice;

  String get customerName;

  String get deliveredTo;

  String get invoiceNo;

  String get invoiceDate;

  String get orderedDate;

  String get invoiceCapital;

  String get product;

  String get price;

  String get subTotal;

  String get phoneNumberInvalid;

  String get placeOrderByMistake;

  String get deliveryTimeIsTooLong;

  String get duplicateOrder;

  String get changeOfMind;

  String get changeOrder;

  String get incorrectIncompleteAddress;

  String get other;

  String get wrongContactInformation;

  String get paymentIssue;

  String get personNotAvailableOnLocation;

  String get invalidCourierPackage;

  String get courierPackageIsNotAsPerOrder;

  String get invalidOrder;

  String get damageCourier;

  String get sentWrongCourier;

  String get notAsOrder;

  String get pleaseSelectValidAddress;

  String get selectedAddressValidation;

  String get orderArrived;

  String get orderActiveSuccessfully;

  String get orderDepartedSuccessfully;

  String get orderDeliveredSuccessfully;

  String get deleteAccount;

  String get deleteAccountMsg1;

  String get deleteAccountMsg2;

  String get deleteAccountConfirmMsg;

  String get remark;

  String get showMore;

  String get showLess;

  String get choosePickupAddress;

  String get chooseDeliveryAddress;

  String get showingAllAddress;

  String get addNewAddress;

  String get selectPickupLocation;

  String get selectDeliveryLocation;

  String get searchAddress;

  String get pleaseWait;

  String get confirmPickupLocation;

  String get confirmDeliveryLocation;

  String get addressNotInArea;

  String get wallet;

  String get bankDetails;

  String get declined;

  String get requested;

  String get approved;

  String get withdraw;

  String get availableBalance;

  String get withdrawHistory;

  String get addMoney;

  String get amount;

  String get addAmount;

  String get credentialNotMatch;

  String get accountNumber;

  String get nameAsPerBank;

  String get ifscCode;

  String get acceptTermService;

  String get iAgreeToThe;

  String get termOfService;

  String get somethingWentWrong;

  String get userNotFound;

  String get balanceInsufficient;

  String get add;

  String get moneyDeposited;

  String get moneyDebited;

  String get bankNotFound;

  String get internetIsConnected;

  String get invalidUrl;

  String get balanceInsufficientCashPayment;

  String get ok;

  String get orderFee;

  String get topup;

  String get orderCancelCharge;

  String get orderCancelRefund;

  String get correction;

  String get commission;

  String get cancelBeforePickMsg;

  String get cancelAfterPickMsg;

  String get cancelNote;

  String get earningHistory;

  String get earning;

  String get adminCommission;

  String get assigned;

  String get draft;

  String get created;

  String get accepted;

  //TODO
  String get vehicle;

  String get add_vehicle;

  String get update_vehicle;

  String get vehicle_size;

  String get vehicle_capacity;

  String get vehicle_image;

  String get select_vehicle;

  String get enable_vehicle;

  String get disable_vehicle;

  String get enable_vehicle_msg;

  String get disable_vehicle_msg;

  String get delete_vehicle;

  String get do_you_want_to_delete_this_vehicle;

  String get vehicle_name;

  String get bankName;

  String get courierAssigned;

  String get courierAccepted;

  String get courierPickedUp;

  String get courierArrived;

  String get courierDeparted;

  String get courierTransfer;

  String get paymentStatusMessage;

  String get rejected;

  String get notChangeMobileNo;

  String get verification;

  String get phoneNumberAlreadyVerified;

  String get verifyPhoneNumber;
}
