// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
    List<Store>? stores;

    CustomerModel({
        this.stores,
    });

    factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        stores: json["stores"] == null ? [] : List<Store>.from(json["stores"]!.map((x) => Store.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "stores": stores == null ? [] : List<dynamic>.from(stores!.map((x) => x.toJson())),
    };
}

class Store {
    String? id;
    String? typename;
    int? caseVolumeLtm;
    dynamic caseVolume2024;
    double? cirocCases;
    double? percentile;
    GeoLocation? geoLocation;

    Store({
        this.id,
        this.typename,
        this.caseVolumeLtm,
        this.caseVolume2024,
        this.cirocCases,
        this.percentile,
        this.geoLocation,
    });

    factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        typename: json["__typename"],
        caseVolumeLtm: json["caseVolumeLTM"],
        caseVolume2024: json["caseVolume2024"],
        cirocCases: json["cirocCases"]?.toDouble(),
        percentile: json["percentile"]?.toDouble(),
        geoLocation: json["geoLocation"] == null ? null : GeoLocation.fromJson(json["geoLocation"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "__typename": typename,
        "caseVolumeLTM": caseVolumeLtm,
        "caseVolume2024": caseVolume2024,
        "cirocCases": cirocCases,
        "percentile": percentile,
        "geoLocation": geoLocation?.toJson(),
    };
}

class GeoLocation {
    double? latitude;
    double? longitude;
    String? typename;

    GeoLocation({
        this.latitude,
        this.longitude,
        this.typename,
    });

    factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        typename: json["__typename"],
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "__typename": typename,
    };
}
