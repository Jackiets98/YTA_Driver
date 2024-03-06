import '../../main/models/WalletListModel.dart';

import '../../main/models/PaginationModel.dart';
import 'VehicleModel.dart';

class OrderListModel {
  PaginationModel? pagination;
  List<OrderData>? data;
  int? allUnreadCount;
  UserWalletModel? walletData;

  OrderListModel(
      {this.pagination, this.data, this.allUnreadCount, this.walletData});

  OrderListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new PaginationModel.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <OrderData>[];
      json['data'].forEach((v) {
        data!.add(new OrderData.fromJson(v));
      });
    }
    allUnreadCount = json['all_unread_count'];
    walletData = json['wallet_data'] != null
        ? new UserWalletModel.fromJson(json['wallet_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['all_unread_count'] = this.allUnreadCount;
    if (this.walletData != null) {
      data['wallet_data'] = this.walletData!.toJson();
    }
    return data;
  }
}

class OrderData {
  String? id;
  String? clientName;
  String? departedDateTime;
  String? item_desc;
  String? contactNumber;
  String? deliveryPoint;
  String? pickupPoint;
  String? cityName;
  String? parcelType;
  String? driverContact;
  num? totalWeight;
  var totalDistance;
  String? pickupDatetime;
  String? deliveryDatetime;
  String? parentOrderId;
  String? status;
  int? paymentId;
  String? paymentType;
  String? paymentStatus;
  String? paymentCollectFrom;
  String? deliveryManId;
  String? deliveryManName;
  num? fixedCharges;
  var extraCharges;
  var totalAmount;
  String? reason;
  int? pickupConfirmByClient;
  int? pickupConfirmByDeliveryMan;
  num? totalParcel;
  int? vehicleId;
  VehicleData? vehicleData;
  String? vehicleImage;
  bool? isDone;

  OrderData(
      {this.id,
      this.clientName,
      this.departedDateTime,
      this.deliveryPoint,
      this.pickupPoint,
      this.contactNumber,
      this.driverContact,
      this.cityName,
      this.parcelType,
      this.totalWeight,
      this.totalDistance,
      this.pickupDatetime,
      this.deliveryDatetime,
      this.parentOrderId,
      this.status,
      this.paymentId,
      this.paymentType,
      this.paymentStatus,
      this.paymentCollectFrom,
      this.deliveryManId,
      this.deliveryManName,
      this.fixedCharges,
      this.extraCharges,
      this.totalAmount,
      this.reason,
      this.pickupConfirmByClient,
      this.pickupConfirmByDeliveryMan,
      this.totalParcel,
      this.item_desc,
      this.vehicleId,
      this.vehicleData,
      this.vehicleImage,
      this.isDone});

  OrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driverContact = json['driverContact'];
    clientName = json['client_name'];
    departedDateTime = json['date'];
    deliveryPoint = json['delivery_point'] != null
        ? json['delivery_point']
        : null;
    pickupPoint = json['pickup_point'] != null
        ? json['pickup_point']
        : null;
    cityName = json['city_name'];
    contactNumber = json['contact_number'];
    parcelType = json['parcel_type'];
    totalWeight = json['total_weight'];
    totalDistance = json['total_distance'];
    pickupDatetime = json['pickup_datetime'];
    deliveryDatetime = json['delivery_datetime'];
    parentOrderId = json['parent_order_id'];
    status = json['status'];
    isDone = json['isDone'];
    paymentId = json['payment_id'];
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
    paymentCollectFrom = json['payment_collect_from'];
    deliveryManId = json['driver'];
    deliveryManName = json['delivery_man_name'];
    fixedCharges = json['fixed_charges'];
    extraCharges = json['extra_charges'];
    totalAmount = json['total_amount'];
    reason = json['reason'];
    pickupConfirmByClient = json['pickup_confirm_by_client'];
    pickupConfirmByDeliveryMan = json['pickup_confirm_by_delivery_man'];
    totalParcel = json['total_parcel'];
    item_desc = json['item_desc'];
    vehicleId = json['vehicle_id'];
    vehicleData = json['vehicle_data'] != null
        ? new VehicleData.fromJson(json['vehicle_data'])
        : null;
    vehicleImage = json['vehicle_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['isDone'] = this.isDone;
    data['driverContact'] = this.driverContact;
    data['client_name'] = this.clientName;
    data['pickup_point'] = this.pickupPoint;
    data['contact_number'] =this.contactNumber;
    data['date'] = this.departedDateTime;
    data['delivery_point'] = this.deliveryPoint;
    data['city_name'] = this.cityName;
    data['parcel_type'] = this.parcelType;
    data['total_weight'] = this.totalWeight;
    data['total_distance'] = this.totalDistance;
    data['pickup_datetime'] = this.pickupDatetime;
    data['delivery_datetime'] = this.deliveryDatetime;
    data['parent_order_id'] = this.parentOrderId;
    data['status'] = this.status;
    data['payment_id'] = this.paymentId;
    data['payment_type'] = this.paymentType;
    data['payment_status'] = this.paymentStatus;
    data['payment_collect_from'] = this.paymentCollectFrom;
    data['driver'] = this.deliveryManId;
    data['delivery_man_name'] = this.deliveryManName;
    data['fixed_charges'] = this.fixedCharges;
    data['extra_charges'] = this.extraCharges;
    data['total_amount'] = this.totalAmount;
    data['reason'] = this.reason;
    data['pickup_confirm_by_client'] = this.pickupConfirmByClient;
    data['pickup_confirm_by_delivery_man'] = this.pickupConfirmByDeliveryMan;
    data['total_parcel'] = this.totalParcel;
    data['item_desc'] = this.item_desc;
    data['vehicle_id'] = this.vehicleId;
    if (this.vehicleData != null) {
      data['vehicle_data'] = this.vehicleData!.toJson();
    }
    data['vehicle_image'] = this.vehicleImage;
    return data;
  }
}
