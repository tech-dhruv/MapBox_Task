// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
    List<Customer>? customers;

    CustomerModel({
        this.customers,
    });

    factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        customers: json["customers"] == null ? [] : List<Customer>.from(json["customers"]!.map((x) => Customer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customers": customers == null ? [] : List<dynamic>.from(customers!.map((x) => x.toJson())),
    };
}

class Customer {
    String? customerId;
    String? name;
    String? email;
    String? phone;
    String? address;
    String? typename;
    GeoLocation? geoLocation;

    Customer({
        this.customerId,
        this.name,
        this.email,
        this.phone,
        this.address,
        this.typename,
        this.geoLocation,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        customerId: json["customerId"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        typename: json["__typename"],
        geoLocation: json["geoLocation"] == null ? null : GeoLocation.fromJson(json["geoLocation"]),
    );

    Map<String, dynamic> toJson() => {
        "customerId": customerId,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "__typename": typename,
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
