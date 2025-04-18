import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_task/config/app_constants.dart';

import '../data/datasource/repository/base/api_response.dart';
import '../data/repository/auth_repo.dart';
import '../models/response/base/response_model.dart';
import '../utility/toast_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepo authRepo;

  AuthProvider({required this.authRepo});

  bool _isLoading = false;
  bool _isAuthorized = false;

  bool get isAuthorized => _isAuthorized;

  bool get isLoading => _isLoading;

  Future<ResponseModel> login(Map data,) async {
    ResponseModel responseModel;
    _isLoading = true;
    notifyListeners();
    ApiResponse apiRegisterResponse = await authRepo.login();

    if (apiRegisterResponse.response != null &&
        apiRegisterResponse.response!.statusCode == 200) {
      if (apiRegisterResponse.response?.data[AppConstants.API_STATUS] ==
          "success") {
        responseModel = ResponseModel(
            true,
            apiRegisterResponse.response?.data[AppConstants.API_MESSAGE] ?? "",
            2);
        responseModel = ResponseModel(
            true,
            apiRegisterResponse.response?.data[AppConstants.API_MESSAGE] ?? "",
            2);
        ToastService.show("Welcome back");
      } else {
        responseModel = ResponseModel(
            false,
            apiRegisterResponse.response?.data[AppConstants.API_MESSAGE] ?? "",
            null);
      }
    } else {
      // Todo
      responseModel =
          ResponseModel(false, apiRegisterResponse.error ?? "", null);
    }
    if (!responseModel.isSuccess) {
      ToastService.show(responseModel.message, toastLength: Toast.LENGTH_LONG);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> test() async {
    ResponseModel responseModel;
    _isLoading = true;
    ApiResponse apiRegisterResponse = await authRepo.test();

    if (apiRegisterResponse.response != null &&
        apiRegisterResponse.response!.statusCode == 200) {
      responseModel =
          ResponseModel(true, "Success", apiRegisterResponse.response?.data);
      ToastService.show("Success!");
    } else {
      // Todo
      responseModel =
          ResponseModel(false, apiRegisterResponse.response?.data ?? "", null);
      ToastService.show(responseModel.message, toastLength: Toast.LENGTH_LONG);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> logout() async {
    ResponseModel responseModel;
    _isLoading = true;
    try {
      clearSharedData();
      responseModel = ResponseModel(true, "Logout", null);
      _isAuthorized = false;
      await clearSharedData();
    } on Exception catch (e) {
      // TODO
      responseModel = ResponseModel(false, "Logout", null);
      ToastService.show(responseModel.message, toastLength: Toast.LENGTH_LONG);
    }

    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo.clearSharedData();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  void clear() {
    // Clear Provider
    notifyListeners();
  }
}
