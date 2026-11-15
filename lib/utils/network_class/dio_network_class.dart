import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../common_widgets/common_loader.dart';
import '../common_widgets/common_toast.dart';
import '../preference_keys/preference_keys.dart';
import 'api_url_constants.dart';
import 'network_response.dart';

class DioNetworkClass {
  var dio = Dio();
  String endUrl = "";
  String filePath = "";
  String param = "";
  List<String> imageArray = [];
  late NetworkResponse? networkResponse;
  late StateSetter? stateSetter;
  Map<String, dynamic> jsonBody = {};
  int requestCode = 0;
  double progress = 0;

  DioNetworkClass({
    required this.networkResponse,
    required this.endUrl,
    required this.requestCode,
  });

  DioNetworkClass.fromNetworkClass({
    required this.networkResponse,
    required this.endUrl,
    required this.requestCode,
    required this.jsonBody,
  });

  Future<void> callRequestServiceHeader(
    bool showLoader,
    String requestType,
  ) async {
    try {
      if (showLoader && navigatorKey.currentContext != null) {
        CommonLoader.show(navigatorKey.currentContext!);
      }

      Options options = Options(method: requestType.toUpperCase());
      dio.options.connectTimeout = const Duration(seconds: 90);
      options.sendTimeout = const Duration(seconds: 90);
      dio.options.receiveTimeout = const Duration(seconds: 90);
      dio.options.contentType = Headers.jsonContentType;

      String headerToken = "";
      final token = sharedPreferences.getString(PreferenceKeys.tokenKey);
      if (token != null && token.isNotEmpty) {
        headerToken = "Bearer $token";
        options.headers = {
          PreferenceKeys.headerKey: headerToken,
        };
        debugPrint("${requestType}Token: $headerToken");
      }

      debugPrint("Headers: ${options.headers}");
      debugPrint("${requestType}Url: ${baseUrl + endUrl}");

      if (requestType.toLowerCase() == "get" && jsonBody.isNotEmpty) {
        dio.options.queryParameters = jsonBody;
        debugPrint("${requestType}Query Parameters: ${dio.options.queryParameters}");
      } else {
        debugPrint("${requestType}Map: $jsonBody");
      }

      Response response = await dio.request(
        baseUrl + endUrl,
        data: (requestType.toLowerCase() != "get" && jsonBody.isNotEmpty) ? jsonBody : null,
        options: options,
      );

      log("API_Response-> $endUrl::: ${jsonEncode(response.data)}");

      if (CommonLoader.isShowing && navigatorKey.currentContext != null) {
        CommonLoader.hide(navigatorKey.currentContext!);
      }

      if (response.statusCode != null && response.statusCode! <= 201) {
        networkResponse?.onResponse(
          requestCode: requestCode,
          response: jsonEncode(response.data),
        );
      } else {
        debugPrint("Error: $endUrl: ${response.data}");
        networkResponse?.onApiError(
          requestCode: requestCode,
          response: jsonEncode(response.data),
        );
      }
    } on DioException catch (e, str) {
      debugPrint("DioException: $e");
      debugPrint("StackTrace: $str");
      if (CommonLoader.isShowing && navigatorKey.currentContext != null) {
        CommonLoader.hide(navigatorKey.currentContext!);
      }

      if (e.error is SocketException) {
        commonSocketException(
          (e.error as SocketException).osError?.errorCode ?? 0,
          (e.error as SocketException).message,
        );
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response != null && e.response.toString().contains("<!DOCTYPE HTML PUBLIC")) {
          CommonToast.show(
            "Unable to connect to Server",
            backgroundColor: Colors.red,
          );
        }
        debugPrint("Error: $endUrl: ${e.response?.data}");
        networkResponse?.onApiError(
          requestCode: requestCode,
          response: jsonEncode(e.response?.data),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        CommonToast.show("Connection timeout", backgroundColor: Colors.red);
      }
    } catch (err, str) {
      debugPrint("exception: $err");
      debugPrint("StackTrace: $str");
      if (CommonLoader.isShowing && navigatorKey.currentContext != null) {
        CommonLoader.hide(navigatorKey.currentContext!);
      }
      debugPrint('Error While Making network call::::::: $err');
    }
  }

  void commonSocketException(int errorCode, String errorMessage) {
    switch (errorCode) {
      case 7:
      case 8:
        debugPrint("Internet Connection Error");
        CommonToast.show(
          "Internet Connection Error",
          backgroundColor: Colors.red,
        );
        break;
      case 111:
        debugPrint("Unable to connect Server");
        CommonToast.show(
          "Unable to connect to Server",
          backgroundColor: Colors.red,
        );
        break;
      default:
        debugPrint("Unknown Error :$errorMessage");
        CommonToast.show(
          "Unknown Error :$errorMessage",
          backgroundColor: Colors.red,
        );
    }
  }
}
