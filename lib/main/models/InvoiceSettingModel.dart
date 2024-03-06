class InvoiceSettingModel {
    List<InvoiceData>? invoiceData;

    InvoiceSettingModel({this.invoiceData});

    factory InvoiceSettingModel.fromJson(Map<String, dynamic> json) {
        return InvoiceSettingModel(
            invoiceData: json['data'] != null ? (json['data'] as List).map((i) => InvoiceData.fromJson(i)).toList() : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.invoiceData != null) {
            data['data'] = this.invoiceData!.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class InvoiceData {
    int? id;
    String? key;
    String? type;
    String? value;

    InvoiceData({this.id, this.key, this.type, this.value});

    factory InvoiceData.fromJson(Map<String, dynamic> json) {
        return InvoiceData(
            id: json['id'], 
            key: json['key'], 
            type: json['type'], 
            value: json['value'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['key'] = this.key;
        data['type'] = this.type;
        data['value'] = this.value;
        return data;
    }
}