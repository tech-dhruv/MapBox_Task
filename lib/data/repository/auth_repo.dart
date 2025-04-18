import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_constants.dart';
import '../../config/api_constants.dart';
import '../datasource/remote/dio/dio_client.dart';
import '../datasource/remote/exception/api_error_handler.dart';
import '../datasource/repository/base/api_response.dart';

class AuthRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({
    required this.dioClient,
    required this.sharedPreferences,
  });

  Future<ApiResponse> test() async {
    try {
      Response response = await dioClient.get(
        APIConstants.TEST,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> login() async {
    try {
      Response response = await dioClient.post(
        APIConstants.LOGIN,
        data: {}, // data
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.TOKEN) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  Future<bool> clearSharedData() async {
    await sharedPreferences.clear();
    return true;
  }
}
