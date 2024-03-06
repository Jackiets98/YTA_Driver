class PlaceAddressModel {
  double? latitude;
  double? longitude;
  String? placeId;
  String? placeAddress;

  PlaceAddressModel({this.latitude, this.longitude, this.placeId, this.placeAddress});

  factory PlaceAddressModel.fromJson(Map<String, dynamic> json) {
    return PlaceAddressModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeId: json['placeId'],
      placeAddress: json['placeAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['placeId'] = this.placeId;
    data['placeAddress'] = this.placeAddress;
    return data;
  }
}