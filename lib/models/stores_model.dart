// To parse this JSON data, do
//
//     final storeModel = storeModelFromJson(jsonString);

import 'dart:convert';

StoreModel storeModelFromJson(String str) =>
    StoreModel.fromJson(json.decode(str));

String storeModelToJson(StoreModel data) => json.encode(data.toJson());

class StoreModel {
  List<Stores>? stores;

  StoreModel({
    this.stores,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        stores: json["stores"] == null
            ? []
            : List<Stores>.from(json["stores"]!.map((x) => Stores.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "stores": stores == null
            ? []
            : List<dynamic>.from(stores!.map((x) => x.toJson())),
      };
}

class Stores {
  String? id;
  StoreTypename? typename;
  double? caseVolumeLtm;
  dynamic caseVolume2024;
  double? cirocCases;
  double? percentile;
  GeoLocation? geoLocation;

  Stores({
    this.id,
    this.typename,
    this.caseVolumeLtm,
    this.caseVolume2024,
    this.cirocCases,
    this.percentile,
    this.geoLocation,
  });

  factory Stores.fromJson(Map<String, dynamic> json) => Stores(
        id: json["id"],
        typename: storeTypenameValues.map[json["__typename"]]!,
        caseVolumeLtm: json["caseVolumeLTM"]?.toDouble(),
        caseVolume2024: json["caseVolume2024"],
        cirocCases: json["cirocCases"]?.toDouble(),
        percentile: json["percentile"]?.toDouble(),
        geoLocation: json["geoLocation"] == null
            ? null
            : GeoLocation.fromJson(json["geoLocation"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "__typename": storeTypenameValues.reverse[typename],
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
  GeoLocationTypename? typename;

  GeoLocation({
    this.latitude,
    this.longitude,
    this.typename,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        typename: geoLocationTypenameValues.map[json["__typename"]]!,
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "__typename": geoLocationTypenameValues.reverse[typename],
      };
}

enum GeoLocationTypename { POINT }

final geoLocationTypenameValues =
    EnumValues({"Point": GeoLocationTypename.POINT});

enum StoreTypename { STORE }

final storeTypenameValues = EnumValues({"Store": StoreTypename.STORE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
