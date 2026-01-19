import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/log_in_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';
import '../widgets/custom_loading_indicator.dart';


loadingDialog() {
  Get.closeCurrentSnackbar();
  Get.closeAllSnackbars();
  Get.dialog(const Center(child: CustomLoadingIndicator()), barrierDismissible: false,useSafeArea: true);
}

closeLoadingDialog() {
  if(Get.isDialogOpen!){
    Get.back();
  }
}

class NetworkFunctions {

  static String networkErrorMessage = "";
  static bool isNetworkError = false;
  static String serverTakingLong = 'Time out';
  static String internetConnectionProblem = 'Internet connection problem';
  static String somethingWentWrong = 'Something went wrong';


  static void errorDialog(){
    if(Get.isDialogOpen!){
      Get.back();
    }
    showToast(message: networkErrorMessage.toString());
  }

  static void logout(){
    // final DatabaseHelper dbHelper = DatabaseHelper();
    getStorage.write(IS_LOGIN, null);
    getStorage.write(USER_DETAIL, null);
    getStorage.write(BEARER_TOKEN, null);
    getStorage.erase();
    Get.off(() => LogInScreen());

    // getStorage.erase();
  }

  static Future<Map<String, String>> getOurHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': getStorage.read(BEARER_TOKEN)==null ? 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNGYxNjhiNmU5NTdkMDdmNzViMDhhZDdjNzY1N2Y3NDIzNzgzYjRjNDdhNzVkZmJjMTdjMTdlZGFmNDYwMWFiN2MyMDE3ZDUwZjI3Y2UwNzYiLCJpYXQiOjE3NTI0NjgyMzEuMDQ2MDM3LCJuYmYiOjE3NTI0NjgyMzEuMDQ2MDQxLCJleHAiOjE3ODQwMDQyMzEuMDQzNTc3LCJzdWIiOiIxIiwic2NvcGVzIjpbInVzZXItdGFzayJdfQ.c4GR-iJZtAr_BfyGvmD0YtynWwE24M6xMmLy6hXfBr6Gf_7wlrC3RfYWgJY7WgTzjsadbkywsLSptq18wq4J4y5dl35I6bvuSt5IlOHleuhg3yU8OCC_dVPWLqR9h-wjjA1GifIrvkJ8YTpuHtAcBBNRQD5MqvtvKBB5rNxn79A51vAFg4nNvpuUL4t4ZyF8hx2HIWJv-rzmVhXirBlFhsKOEI_iYVkSFprFVQLLX63SrsgCU3fO64wCnT0YbCfoCgcB6-NAcodh-YTDG7rskShN_uaII5TODrNpOGnjZpRqsqWEnBKm-komtJD2Dxdz-BSOC7aMBTSyJERsFORhHMhCQ3cMjyv7WXkf2upIC8ZIiJOPn_JTjZUN23Edt5pzZC1g-I_Q9q18RcnoVIb25q353YXo1cjBImBsSePFyifgQA0kWmP8davxcSFblT50aCMoDXSNNgRSOjq-btUzeY1reNGbEBoDx3fWIFJjtvAvIsWrCE_T6518ysDSyRLx3n8zEkO_ZMxShc_EloXhQBYa7WTSF_GQpj2-pAnMLpZM3AntF-chBK-2CD8gxkcg7Y7zkHhkEzLOd1mRO_mb97yXHANGUkjsbR0-8bwIBvQ2DDIXXGEJ8ajFLbZCwdcFCEnPXwds0Jzck5zNLs9Sc0jh3scpaGQppB07tlqePG4' : 'Bearer ${getStorage.read(BEARER_TOKEN)}',
    };
    return headers;
  }

  static Future<http.Response?> apiRequest({
    required String url,
    required bool isShowLoader,
    String? method,
    dynamic body,
    bool isShowError = true,
    bool sendAsFormData = false,
  }) async {
    http.Response response;
    Timer? timer;
    try {
      Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();
      if (isShowLoader) {
        loadingDialog();
      }

      isNetworkError = false; // Reset the flag

      int secondsElapsed = 0;
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        secondsElapsed++;
        debugPrint('⏱ API waiting... $secondsElapsed second(s)');
      });

      Map<String, String> headers = await getOurHeaders();

      // Modify headers for form data
      if (sendAsFormData) {
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      }

      if (method == 'get') {
        debugPrint('$url?${Uri(queryParameters: body).query}');
        response = await http.get(
            Uri.parse('$url?${Uri(queryParameters: body).query}'),
            headers: headers
        ).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else if (method == 'delete') {
        response = await http.delete(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else if (method == 'put') {
        debugPrint(url);
        String requestBody = sendAsFormData ?
        Uri(queryParameters: Map<String, String>.from(body)).query :
        jsonEncode(body);
        debugPrint(requestBody);

        response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: requestBody
        ).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else {
        debugPrint(url);
        debugPrint(json.encode(body));
        String requestBody = sendAsFormData ?
        Uri(queryParameters: Map<String, String>.from(body)).query :
        jsonEncode(body);



        response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: requestBody
        ).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }

      timer.cancel();

      if (isShowLoader) {
        Get.back();
      }

      if (response.statusCode == 200) {
        return response;
      }
      else if (response.statusCode == 401) {
        logout();
      }
      else if (response.statusCode == 500) {
        showToast(message: 'internal_server_error'.tr);
      }

    } catch (e) {
      timer?.cancel();

      if (e is TimeoutException) {
        isNetworkError = true;
        networkErrorMessage = serverTakingLong.tr;
      } else if (e is SocketException || e is http.ClientException || e is HandshakeException) {
        isNetworkError = true;
        networkErrorMessage = internetConnectionProblem.tr;
      } else {
        isNetworkError = true;
        networkErrorMessage = somethingWentWrong.tr;
      }
      debugPrint(e.toString());
    }

    if (isNetworkError) {
      if (isShowLoader) {
        Get.back();
      }
      if (isShowError) {
        showToast(message: networkErrorMessage.tr);
      }
    }

    return null;
  }

/*  static Future<http.Response?> apiRequest({
    required String url,
    required bool isShowLoader,
    String? method,
    // Map<String,dynamic>? body,
    dynamic body,
    bool isShowError = true
  }) async {
    http.Response response;
    Timer? timer;
    try {
      Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();
      if (isShowLoader) {
        loadingDialog();
      }
      int secondsElapsed = 0;
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        secondsElapsed++;
        debugPrint('⏱ API waiting... $secondsElapsed second(s)');
      });



      Map<String, String> headers = await getOurHeaders();
      if (method == 'get') {
        debugPrint('$url?${Uri(queryParameters: body).query}');
        response = await http.get(Uri.parse('$url?${Uri(*//*queryParameters: body*//*).query}'), headers: headers).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else if (method == 'delete') {
        response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else if (method == 'put') {
        debugPrint(url);
        debugPrint(json.encode(body));
        response = await http.put(Uri.parse(url), headers: headers,body: jsonEncode(body)).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }
      else {
        debugPrint(url);
        debugPrint(json.encode(body));
        response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 60));
        debugPrint("status Response::::::${response.body}");
      }

      if (isShowLoader) {
        Get.back();
      }
      if (response.statusCode == 200) {
        timer.cancel();
        return response;
      }
      else if (response.statusCode == 401) {
        timer.cancel();
        logout();
      }
      else if (response.statusCode == 500) {
        timer.cancel();
        showToast(message: 'internal_server_error'.tr);
      }

      timer.cancel();

    } on TimeoutException catch (e) {
      isNetworkError = true;
      networkErrorMessage = serverTakingLong.tr;
      debugPrint(e.toString());
      timer!.cancel();

    } on SocketException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
      timer!.cancel();

    } on http.ClientException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
      timer!.cancel();

    } on HandshakeException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
      timer!.cancel();

    } on Error catch (e) {
      isNetworkError = true;
      networkErrorMessage = somethingWentWrong.tr;
      debugPrint(e.toString());
      timer!.cancel();

    }
    if(isNetworkError){
      if (isShowLoader) {
        Get.back();
      }
      if(isShowError) {
        showToast(message: networkErrorMessage.tr);
      }
    }
    timer.cancel();
    return null;
  }*/

  static Future<http.Response?> multiPartApiRequestWithImage({
    required String url,
    required bool isShowLoader,
    required String imageParam,
    required String imagePath,
    Map<String,String>? body,
  }) async {
    try {
      Get.closeAllSnackbars();
      if (isShowLoader) {
        Get.dialog(const Center(child: CustomLoadingIndicator()), barrierDismissible: false);
      }
      Map<String, String> headers = await getOurHeaders();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      if(imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(imageParam,imagePath
          // ApiKey.file,
          // data![ApiKey.uploadFilePath],
        ));
      }
      if(body!=null) {
        request.fields.addAll(body);
      }
      var response = await request.send();

      if (isShowLoader) {
        Get.back();
      }
      // final responseFromStream = await http.Response.fromStream(response);
      // print(responseFromStream.body);

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final responseFromStream = await http.Response.fromStream(response);
        return responseFromStream;
      } else if (response.statusCode == 401) {
        logout();
      }
      else if (response.statusCode == 500) {
        showToast(message: 'internal_server_error'.tr);
      }
    } on TimeoutException catch (e) {
      isNetworkError = true;
      networkErrorMessage = serverTakingLong.tr;
      debugPrint(e.toString());
    } on SocketException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
    } on http.ClientException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
    } on HandshakeException catch (e) {
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem.tr;
      debugPrint(e.toString());
    } on Error catch (e) {
      isNetworkError = true;
      networkErrorMessage = somethingWentWrong.tr;
      debugPrint(e.toString());
    }
    if(isNetworkError){
      if (isShowLoader) {
        Get.back();
      }
      showToast(message: networkErrorMessage.tr);
    }
    return null;
  }
}