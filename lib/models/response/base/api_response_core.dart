import 'package:mapbox_task/models/response/base/i_api_response_core.dart';

class ApiResponseCore<T extends IApiResponseCore> {
  T? data;
  String? message;
  bool? status;

  ApiResponseCore({this.data, this.message, this.status});

  ApiResponseCore.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    if (json['data'] != null) {
      data = fromJsonT(json['data']);
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson(Function(T value) toJson) {
    final Map<String, dynamic> json = <String, dynamic>{};
    final Map<String, dynamic> dataJson =
        data != null ? toJson(data!) : <String, dynamic>{};
    json['data'] = dataJson;
    json['message'] = message;
    json['status'] = status;
    return json;
  }
}
