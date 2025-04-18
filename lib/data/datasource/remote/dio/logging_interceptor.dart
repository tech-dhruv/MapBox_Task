import 'dart:developer';

import 'package:dio/dio.dart';

String black = "\x1B[30m";
String red = "\x1B[31m";
String green = "\x1B[32m";
String yellow = "\x1B[33m";
String blue = "\x1B[94m";
String magenta = "\x1B[35m";
String cyan = "\x1B[36m";
String white = "\x1B[37m";
String reset = "\x1B[0m";

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 100;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log("$blue--> ${options.method} ${options.path}");
    log("${blue}Headers: ${options.headers.toString()}");
    log("${blue}Data --> ${options.data}");
    log("$blue<-- END HTTP");

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    log("$blue<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
    log("$blue${response.data}");
    log("$blue<-- END HTTP");

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    log("$red Error[${err.response?.statusCode}]--> PATH: ${err.requestOptions.path} $red");
    log("$red ERROR <-- ${err.response}$red");
    return super.onError(err, handler);
  }
}
