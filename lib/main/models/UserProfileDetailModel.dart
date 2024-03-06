import '../models/PaginationModel.dart';
import 'LoginResponse.dart';

class UserProfileDetailModel {
  UserData? data;
  WalletHistory? walletHistory;
  EarningDetail? earningDetail;
  EarningList? earningList;

  UserProfileDetailModel(
      {this.data, this.walletHistory, this.earningDetail, this.earningList});

  UserProfileDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new UserData.fromJson(json['data']) : null;
    walletHistory = json['wallet_history'] != null
        ? new WalletHistory.fromJson(json['wallet_history'])
        : null;
    earningDetail = json['earning_detail'] != null
        ? new EarningDetail.fromJson(json['earning_detail'])
        : null;
    earningList = json['earning_list'] != null
        ? new EarningList.fromJson(json['earning_list'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.walletHistory != null) {
      data['wallet_history'] = this.walletHistory!.toJson();
    }
    if (this.earningDetail != null) {
      data['earning_detail'] = this.earningDetail!.toJson();
    }
    if (this.earningList != null) {
      data['earning_list'] = this.earningList!.toJson();
    }
    return data;
  }
}

class WalletHistory {
  PaginationModel? pagination;
  List<WalletData>? data;

  WalletHistory({this.pagination, this.data});

  WalletHistory.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new PaginationModel.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <WalletData>[];
      json['data'].forEach((v) {
        data!.add(new WalletData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletData {
  int? id;
  int? userId;
  String? userName;
  String? type;
  String? transactionType;
  String? currency;
  num? amount;
  num? balance;
  num? walletBalance;
  String? datetime;
  int? orderId;
  String? description;
  WalletPaymentData? data;
  String? createdAt;
  String? updatedAt;

  WalletData(
      {this.id,
        this.userId,
        this.userName,
        this.type,
        this.transactionType,
        this.currency,
        this.amount,
        this.balance,
        this.walletBalance,
        this.datetime,
        this.orderId,
        this.description,
        this.data,
        this.createdAt,
        this.updatedAt});

  WalletData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    type = json['type'];
    transactionType = json['transaction_type'];
    currency = json['currency'];
    amount = json['amount'];
    balance = json['balance'];
    walletBalance = json['wallet_balance'];
    datetime = json['datetime'];
    orderId = json['order_id'];
    description = json['description'];
    data = json['data'] != null ? new WalletPaymentData.fromJson(json['data']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['type'] = this.type;
    data['transaction_type'] = this.transactionType;
    data['currency'] = this.currency;
    data['amount'] = this.amount;
    data['balance'] = this.balance;
    data['wallet_balance'] = this.walletBalance;
    data['datetime'] = this.datetime;
    data['order_id'] = this.orderId;
    data['description'] = this.description;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class WalletPaymentData {
  int? paymentId;
  num? tip;
  int? orderHistory;
  num? deliveryManCommission;
  num? adminCommission;

  WalletPaymentData(
      {this.paymentId,
        this.tip,
        this.orderHistory,
        this.deliveryManCommission,
        this.adminCommission});

  WalletPaymentData.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    tip = json['tip'];
    orderHistory = json['order_history'];
    deliveryManCommission = json['delivery_man_commission'];
    adminCommission = json['admin_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_id'] = this.paymentId;
    data['tip'] = this.tip;
    data['order_history'] = this.orderHistory;
    data['delivery_man_commission'] = this.deliveryManCommission;
    data['admin_commission'] = this.adminCommission;
    return data;
  }
}

class EarningDetail {
  int? id;
  String? name;
  num? walletBalance;
  num? totalWithdrawn;
  num? adminCommission;
  num? deliveryManCommission;
  int? totalOrder;
  int? paidOrder;

  EarningDetail(
      {this.id,
        this.name,
        this.walletBalance,
        this.totalWithdrawn,
        this.adminCommission,
        this.deliveryManCommission,
        this.totalOrder,
        this.paidOrder});

  EarningDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    walletBalance = json['wallet_balance'];
    totalWithdrawn = json['total_withdrawn'];
    adminCommission = json['admin_commission'];
    deliveryManCommission = json['delivery_man_commission'];
    totalOrder = json['total_order'];
    paidOrder = json['paid_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['wallet_balance'] = this.walletBalance;
    data['total_withdrawn'] = this.totalWithdrawn;
    data['admin_commission'] = this.adminCommission;
    data['delivery_man_commission'] = this.deliveryManCommission;
    data['total_order'] = this.totalOrder;
    data['paid_order'] = this.paidOrder;
    return data;
  }
}

class EarningList {
  PaginationModel? pagination;
  List<EarningData>? data;

  EarningList({this.pagination, this.data});

  EarningList.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new PaginationModel.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <EarningData>[];
      json['data'].forEach((v) {
        data!.add(new EarningData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EarningData {
  int? id;
  int? orderId;
  int? clientId;
  String? clientName;
  String? orderStatus;
  String? datetime;
  num? totalAmount;
  String? paymentType;
  String? txnId;
  String? paymentStatus;
  var transactionDetail;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  num? cancelCharges;
  num? adminCommission;
  String? receivedBy;
  num? deliveryManFee;
  num? deliveryManTip;
  num? deliveryManCommission;

  EarningData(
      {this.id,
        this.orderId,
        this.clientId,
        this.clientName,
        this.orderStatus,
        this.datetime,
        this.totalAmount,
        this.paymentType,
        this.txnId,
        this.paymentStatus,
        this.transactionDetail,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.cancelCharges,
        this.adminCommission,
        this.receivedBy,
        this.deliveryManFee,
        this.deliveryManTip,
        this.deliveryManCommission});

  EarningData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    orderStatus = json['order_status'];
    datetime = json['datetime'];
    totalAmount = json['total_amount'];
    paymentType = json['payment_type'];
    txnId = json['txn_id'];
    paymentStatus = json['payment_status'];
   /* if (json['transaction_detail'] != null) {
      transactionDetail = <Null>[];
      json['transaction_detail'].forEach((v) {
        transactionDetail!.add(new Null.fromJson(v));
      });
    }*/
    transactionDetail = json['transaction_detail'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    cancelCharges = json['cancel_charges'];
    adminCommission = json['admin_commission'];
    receivedBy = json['received_by'];
    deliveryManFee = json['delivery_man_fee'];
    deliveryManTip = json['delivery_man_tip'];
    deliveryManCommission = json['delivery_man_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['order_status'] = this.orderStatus;
    data['datetime'] = this.datetime;
    data['total_amount'] = this.totalAmount;
    data['payment_type'] = this.paymentType;
    data['txn_id'] = this.txnId;
    data['payment_status'] = this.paymentStatus;
    /*if (this.transactionDetail != null) {
      data['transaction_detail'] =
          this.transactionDetail!.map((v) => v.toJson()).toList();
    }*/
    data['transaction_detail'] = this.transactionDetail;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['cancel_charges'] = this.cancelCharges;
    data['admin_commission'] = this.adminCommission;
    data['received_by'] = this.receivedBy;
    data['delivery_man_fee'] = this.deliveryManFee;
    data['delivery_man_tip'] = this.deliveryManTip;
    data['delivery_man_commission'] = this.deliveryManCommission;
    return data;
  }
}
