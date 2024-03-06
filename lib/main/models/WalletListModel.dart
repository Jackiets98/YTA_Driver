import 'PaginationModel.dart';

class WalletListModel {
  List<WalletModel>? data;
  PaginationModel? pagination;
  UserWalletModel? walletBalance;

  WalletListModel({this.data, this.pagination, this.walletBalance});

  factory WalletListModel.fromJson(Map<String, dynamic> json) {
    return WalletListModel(
     data: json['data'] != null ? (json['data'] as List).map((i) => WalletModel.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
      walletBalance: json['wallet_data'] != null ? UserWalletModel.fromJson(json['wallet_data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.walletBalance != null) {
      data['wallet_data'] = this.walletBalance!.toJson();
    }
    return data;
  }
}

class WalletModel {
  int? id;
  int? userId;
  String? userName;
  String? type;
  String? transactionType;
  String? currency;
  var amount;
  var balance;
  var walletBalance;
  String? datetime;
  int? orderId;
  String? description;
  Data? data;
  String? createdAt;
  String? updatedAt;

  WalletModel({
    this.id,
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
    this.updatedAt
  });

  WalletModel.fromJson(Map<String, dynamic> json) {
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
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  int? paymentId;
  var cancelCharges;
  int? orderHistory;

  Data({this.paymentId, this.cancelCharges, this.orderHistory});

  Data.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    cancelCharges = json['cancel_charges'];
    orderHistory = json['order_history'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_id'] = this.paymentId;
    data['cancel_charges'] = this.cancelCharges;
    data['order_history'] = this.orderHistory;
    return data;
  }
}

class UserWalletModel {
  int? id;
  int? userId;
  var totalAmount;
  int? onlineReceived;
  int? collectedCash;
  var manualReceived;
  int? totalWithdrawn;
  String? currency;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  UserWalletModel(
      {this.id, this.userId, this.totalAmount, this.onlineReceived, this.collectedCash, this.manualReceived, this.totalWithdrawn, this.currency, this.createdAt, this.updatedAt, this.deletedAt});

  UserWalletModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    totalAmount = json['total_amount'];
    onlineReceived = json['online_received'];
    collectedCash = json['collected_cash'];
    manualReceived = json['manual_received'];
    totalWithdrawn = json['total_withdrawn'];
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['total_amount'] = this.totalAmount;
    data['online_received'] = this.onlineReceived;
    data['collected_cash'] = this.collectedCash;
    data['manual_received'] = this.manualReceived;
    data['total_withdrawn'] = this.totalWithdrawn;
    data['currency'] = this.currency;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
