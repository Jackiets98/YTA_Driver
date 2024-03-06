
import 'PaginationModel.dart';
import 'WalletListModel.dart';

class WithDrawListModel {
  List<WithDrawModel>? data;
  PaginationModel? pagination;
  UserWalletModel? walletBalance;

  WithDrawListModel({this.data, this.pagination, this.walletBalance});

  factory WithDrawListModel.fromJson(Map<String, dynamic> json) {
    return WithDrawListModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => WithDrawModel.fromJson(i)).toList() : null,
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

class WithDrawModel {
  int? id;
  int? userId;
  String? userName;
  var amount;
  String? currency;
  String? status;
  String? createdAt;
  String? updatedAt;

  WithDrawModel(
      {this.id,
        this.userId,
        this.userName,
        this.amount,
        this.currency,
        this.status,
        this.createdAt,
        this.updatedAt});

  WithDrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
