
import 'PaginationModel.dart';

class VehicleListModel {
  PaginationModel? pagination;
  List<VehicleData>? data;

  VehicleListModel({this.pagination, this.data});

  VehicleListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <VehicleData>[];
      json['data'].forEach((v) {
        data!.add(new VehicleData.fromJson(v));
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

class VehicleData {
  int? id;
  String? title;
  String? type;
  String? size;
  String? capacity;
  List<String>? cityIds;
  Map<String, dynamic>? cityText;
  int? status;
  String? description;
  String? vehicleImage;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  VehicleData({
    this.id,
    this.title,
    this.type,
    this.size,
    this.capacity,
    this.cityIds,
    this.cityText,
    this.status,
    this.description,
    this.vehicleImage,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  VehicleData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    size = json['size'];
    capacity = json['capacity'];
    cityIds = json['city_ids'] != null ? new List<String>.from(json['city_ids']) : null;
    cityText = json['city_text'];
    status = json['status'];
    description = json['description'];
    vehicleImage = json['vehicle_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['size'] = this.size;
    data['capacity'] = this.capacity;
    data['city_ids'] = this.cityIds;
    data['city_text'] = this.cityText;
    data['status'] = this.status;
    data['description'] = this.description;
    data['vehicle_image'] = this.vehicleImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
