import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/ui/Login.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/persistence/data/shared_prefs_keys.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'apis.dart';

Duration timeoutDuration = Duration(seconds: 30);

class ApiHandler {

  //MARK:-Header.
  static headers() async {
    String? deviceId = "deviceId";
    String? deviceType = "deviceType";
    String? appVersion = "appVersion";
    String? token = "token";

    SharedPreferences? pref = await SharedPreferences.getInstance();
    deviceId = pref.getString(SharedPrefsKeys.deviceId);
    deviceType = pref.getString(SharedPrefsKeys.deviceType);
    appVersion = pref.getString(SharedPrefsKeys.appVersion);
    token = pref.getString(SharedPrefsKeys.token);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "app_version": appVersion ?? "-",
      "device_id": deviceId ?? "-",
      "device_type": deviceType ?? "-",
      "token": token ?? "-"
    };
    return header;
  }

  //MARK:-Function HitApi.
  static put(Map requestBody, String methodName, BuildContext context,
      ValueSetter<Map> callback) async {
    print(methodName);
    print(requestBody);
    try {
      var response = await http
          .put(Uri.parse(methodName),
              body: json.encode(requestBody),
              headers: await ApiHandler.headers())
          .timeout(timeoutDuration);
      var responseData = json.decode(response.body);
      print("responseData  ${response.statusCode}");
      if (response.statusCode == 401) {
        hideLoader(() {
          Navigator.pop(context);
        });
        showAlert(context, (responseData["message"] ?? ""), () {
          //            logoutApi(context);
          clearUserData(context);
        }, isWarning: true);
      } else {
        print(responseData);
        hideLoader(() {
          Navigator.pop(context);
        });
        if (responseData["status"] == 401) {
          showAlert(context, (responseData["message"] ?? ""), () {
            logoutApi(context);
            clearUserData(context);
          }, isWarning: true);
        } else if (responseData["status"] == 1) {
          callback(responseData);
        } else {
          if (methodName == ApiNames.syncData ||
              methodName == ApiNames.login) {
            callback(responseData);
          }
          showAlert(context, responseData["message"], () {
            Navigator.pop(context);
          }, actionTitle: AlertTitle.ok, isFail: true);
        }
      }
    } catch (e) {
      if (methodName == ApiNames.syncData || methodName == ApiNames.login) {
        callback({"status": 0, "message": e.toString()});
      }
      hideLoader(() {
        Navigator.pop(context);
      });
      showAlert(context, AppMessage.wrongUrl, () {
        Navigator.pop(context);
      }, actionTitle: AlertTitle.ok, isFail: true);
    }
  }

  static post(Map requestBody, String methodName, BuildContext context,
      ValueSetter<Map> callback) async {
    print(methodName);
    print(requestBody);
    try {
      var response = await http
          .post(Uri.parse(methodName),
              body: json.encode(requestBody),
              headers: await ApiHandler.headers())
          .timeout(timeoutDuration);

      var responseData = json.decode(response.body);
      print("responseData  ${responseData.toString()}");
      print("responseCode  ${response.statusCode}");
      if (response.statusCode == 401) {
        hideLoader(() {
          Navigator.pop(context);
        });
        showAlert(context, (responseData["message"] ?? ""), () {
//          logoutApi(context);
          clearUserData(context);
        }, isWarning: true);
      } else {
        print(responseData);
        hideLoader(() {
          Navigator.pop(context);
        });
        if (responseData["status"] == 401) {
          showAlert(context, (responseData["message"] ?? ""), () {
//            logoutApi(context);
            clearUserData(context);
          }, isWarning: true);
        } else if (responseData["status"] == 1) {
          print("response : get api: $responseData");
          callback(responseData);
        } else {
          if (methodName == ApiNames.syncData ||
              methodName == ApiNames.login) {
            callback(responseData);
          }
          showAlert(context, responseData["message"], () {
            Navigator.pop(context);
          }, actionTitle: AlertTitle.ok, isFail: true);
        }
      }
    } catch (e) {
      if (methodName == ApiNames.syncData || methodName == ApiNames.login) {
        callback({"status": 0, "message": e.toString()});
      }
      hideLoader(() {
        Navigator.pop(context);
      });
      showAlert(context, AppMessage.wrongUrl, () {
        Navigator.pop(context);
      }, actionTitle: AlertTitle.ok, isFail: true);
    }
  }

  //MARK:-Hit API with get.
  static get(String methodName, BuildContext context, ValueSetter<Map> callback,
      {bool hideLoaderState = true, bool isFromSplash = false}) async {
    print("Base Url in getCompany Name...$methodName");
    try {
      var response = await http
          .get(Uri.parse(methodName), headers: await ApiHandler.headers())
          .timeout(timeoutDuration);
      var x = await ApiHandler.headers();
      print("Header from get : $x");

      var responseData = json.decode(response.body);
      if (response.statusCode == 401) {
        if (hideLoaderState == true) {
          hideLoader(() {
            Navigator.pop(context);
          });
        }
        showAlert(context, (responseData["message"] ?? ""), () {
//          logoutApi(context);
          clearUserData(context);
        }, isWarning: true);
      } else {
        print(responseData);
        if (hideLoaderState == true) {
          hideLoader(() {
            Navigator.pop(context);
          });
        }
        if (responseData["status"] == 401) {
          showAlert(context, (responseData["message"] ?? ""), () {
            clearUserData(context);
          }, isWarning: true);
        } else if (responseData["status"] == 1) {
          print("response : get api: $responseData");
          callback(responseData);
        } else {
          if (methodName == ApiNames.companyName) {
            callback(responseData);
          } else {
            showAlert(context, responseData["message"], () {
              Navigator.pop(context);
            }, actionTitle: AlertTitle.ok, isFail: true);
          }
        }
      }
    } catch (e) {
      hideLoader(() {
        Navigator.pop(context);
      });

      if (isFromSplash) {
        showAlert(
            context, "you have to change your IP or Internet configuration",
            () {
          Navigator.pop(context);
          //Redirect on login screen
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => Login()));
        }, actionTitle: AlertTitle.ok, isFail: true);
      } else if (methodName == ApiNames.companyName) {
        callback({"status": 0, "message": e.toString()});
      } else {
        showAlert(context, e.toString(), () {
          Navigator.pop(context);
        }, actionTitle: AlertTitle.ok, isFail: true);
      }
    }
  }

  // static uploadResume(BuildContext context) {
  //   var request = http.MultipartRequest('POST', Uri.parse(ApiHandler.uploadCv));
  //   request.headers.addAll(headers);
  //   request.fields.addAll(requestBody);
  //
  //   if (files?.isNotEmpty ?? false) {
  //     String _filesKey = files?.keys.first ?? '';
  //     bool _hasMultipleFiles = false;
  //
  //     print('files?[_filesKey]: ${files?[_filesKey]}');
  //     print(
  //         'files?[_filesKey].runtimeType == List<File>: ${files?[_filesKey].runtimeType == List<File>}');
  //
  //     if (files?[_filesKey].runtimeType == List<File>) {
  //       _hasMultipleFiles = true;
  //     }
  //
  //     // Multiple files
  //     if (_hasMultipleFiles) {
  //       List<File> _files = files?[_filesKey] ?? [];
  //       int i = 0;
  //       for (final File file in (_files)) {
  //         print("GETTING FILE: $i");
  //         final fileName = path.basename(file.path);
  //         final bytes = await compute(
  //           UniversalFunctions.compressFileToBytes,
  //           file,
  //         );
  //         request.files.add(http.MultipartFile.fromBytes(
  //           "$_filesKey[$i]",
  //           bytes,
  //           filename: fileName,
  //         ));
  //         i++;
  //       }
  //     }
  //
  //     // Single file
  //     else {
  //       print('INSIDE SINGLE FILE');
  //
  //       File file = files?[_filesKey];
  //       final fileName = path.basename(file.path);
  //       final bytes = await compute(
  //         UniversalFunctions.compressFileToBytes,
  //         file,
  //       );
  //       request.files.add(http.MultipartFile.fromBytes(
  //         _filesKey,
  //         bytes,
  //         filename: fileName,
  //       ));
  //     }
  //   }
  //
  //   print('request body: ${request.fields}');
  //
  //   response = await request.send();
  //   responseBody = await response.stream.bytesToString();
  // }

  static Future<String?> uploadUserResume(File file) async {
    print("UPLOADING IMAGE");
    var url = Uri.parse('${ApiNames.uploadCv}'); //get url

    String? deviceId = "deviceId";
    String? deviceType = "deviceType";
    String? appVersion = "appVersion";
    String? token = "token";

    SharedPreferences? pref = await SharedPreferences.getInstance();
    deviceId = pref.getString(SharedPrefsKeys.deviceId);
    deviceType = pref.getString(SharedPrefsKeys.deviceType);
    appVersion = pref.getString(SharedPrefsKeys.appVersion);
    token = pref.getString(SharedPrefsKeys.token);

    print("Token $token User Image");

    Map<String, String> headers = {
      "Content-Type": "multipart/form-data",
      "app_version": appVersion ?? "-",
      "device_id": deviceId ?? "-",
      "device_type": deviceType ?? "-",
      "token": token ?? "-"
    };

    print("Headers :::: $headers");

    http.MultipartRequest request =
        new http.MultipartRequest("PUT", url); //changed

    request.headers.addAll(headers);
    final fileName = path.basename(file.path);
    var bytes = await file.readAsBytes();

    request.files.add(new http.MultipartFile.fromBytes(
      "file",
      bytes,
      filename: fileName,
    ));
    http.StreamedResponse response = await request.send();
    print("UPLOADED :::: $response");
    var responseBody = await response.stream.bytesToString();
    print("STATUS CODE: $responseBody");
    return responseBody;
  }

  static logoutApi(BuildContext context) async {
    showLoader(context, "");
    ApiHandler.get(ApiNames.logout, context, (response) {
      if (response["status"] == 1) {}
    });
  }
}
