// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:backfour/network/models/api_error.dart';
// import 'package:backfour/network/models/method_type.dart';
// import 'package:backfour/utils/universal_functions.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
//
// class APIManager {
//   APIManager._();
//
//   static const Duration _timeoutDuration = Duration(seconds: 60);
//
//   // Pagination
//   static const int firstPageNumber = 1;
//   static const int pageSize = 20;
//
//   static Map<String, String> defaultHeaders = {
//     "Content-Type": "application/json",
//     // "device_type": isAndroid() ? "1" : "2",
//     // "app_version": appPackageInfo?.version ?? "1.0.0",
//   };
//
//   // POST method
//   static Future<dynamic> post({
//     required dynamic requestBody,
//     required String url,
//     Map<String, String> additionalHeaders = const {},
//   }) async {
//     return await _hitApi(
//       url: url,
//       methodType: MethodType.post,
//       requestBody: requestBody,
//       additionalHeaders: additionalHeaders,
//     );
//   }
//
//   // GET method
//   static Future<dynamic> get({
//     required String url,
//     Map<String, String> additionalHeaders = const {},
//   }) async {
//     return await _hitApi(
//       url: url,
//       methodType: MethodType.get,
//       additionalHeaders: additionalHeaders,
//     );
//   }
//
//   // PUT method
//   static Future<dynamic> put({
//     required dynamic requestBody,
//     required String url,
//     Map<String, String> additionalHeaders = const {},
//   }) async {
//     return await _hitApi(
//       url: url,
//       methodType: MethodType.put,
//       requestBody: requestBody,
//       additionalHeaders: additionalHeaders,
//     );
//   }
//
//   // DELETE method
//   static Future<dynamic> delete({
//     required String url,
//     Map<String, String> additionalHeaders = const {},
//   }) async {
//     return await _hitApi(
//       url: url,
//       methodType: MethodType.delete,
//       additionalHeaders: additionalHeaders,
//     );
//   }
//
//   // MULTIPART POST method
//   static Future<dynamic> multiPartPost({
//     required String url,
//     Map<String, String> additionalHeaders = const {},
//     required dynamic requestBody,
//     required Map<String, dynamic> files,
//   }) async {
//     return await _hitApi(
//       url: url,
//       methodType: MethodType.multipartPost,
//       additionalHeaders: additionalHeaders,
//       requestBody: requestBody,
//       files: files,
//     );
//   }
//
//   // Generic HTTP method
//   static Future<dynamic> _hitApi({
//     required MethodType methodType,
//     required String url,
//     dynamic requestBody,
//     Map<String, dynamic>? files,
//     Map<String, String> additionalHeaders = const {},
//   }) async {
//     Completer<dynamic> completer = Completer<dynamic>();
//
//     try {
//       bool hasInternetConnection =
//           await UniversalFunctions.hasInternetConnection;
//       if (!hasInternetConnection) {
//         UniversalFunctions.showErrorAlert(
//           title: 'Internet connection lost',
//         );
//         return;
//       }
//       Map<String, String> headers = {};
//       headers.addAll(defaultHeaders);
//       headers.addAll(additionalHeaders);
//       dynamic response;
//       dynamic responseBody;
//       bool _isMultipartResponse = false;
//       var uri = Uri.parse(url);
//
//       print("requestBody : ${json.encode(requestBody)}"); //todo
//       print("url: ${url} ");
//       print("headers: ${headers}");
//       // print("authAccessToken: ${authAccessToken}");
//
//       switch (methodType) {
//         case MethodType.post:
//           response = await http
//               .post(
//                 uri,
//                 body: json.encode(requestBody),
//                 headers: headers,
//               )
//               .timeout(_timeoutDuration);
//           break;
//         case MethodType.get:
//           response = await http
//               .get(
//                 uri,
//                 headers: headers,
//               )
//               .timeout(_timeoutDuration);
//           break;
//         case MethodType.put:
//           response = await http
//               .put(
//                 uri,
//                 body: json.encode(requestBody),
//                 headers: headers,
//               )
//               .timeout(_timeoutDuration);
//           break;
//         case MethodType.delete:
//           response = await http
//               .delete(
//                 uri,
//                 headers: headers,
//               )
//               .timeout(_timeoutDuration);
//           break;
//         case MethodType.multipartPost:
//           var request = http.MultipartRequest('POST', uri);
//           request.headers.addAll(headers);
//           request.fields.addAll(requestBody);
//
//           if (files?.isNotEmpty ?? false) {
//             String _filesKey = files?.keys.first ?? '';
//             bool _hasMultipleFiles = false;
//
//             print('files?[_filesKey]: ${files?[_filesKey]}');
//             print(
//                 'files?[_filesKey].runtimeType == List<File>: ${files?[_filesKey].runtimeType == List<File>}');
//
//             if (files?[_filesKey].runtimeType == List<File>) {
//               _hasMultipleFiles = true;
//             }
//
//             // Multiple files
//             if (_hasMultipleFiles) {
//               List<File> _files = files?[_filesKey] ?? [];
//               int i = 0;
//               for (final File file in (_files)) {
//                 print("GETTING FILE: $i");
//                 final fileName = path.basename(file.path);
//                 final bytes = await compute(
//                   UniversalFunctions.compressFileToBytes,
//                   file,
//                 );
//                 request.files.add(http.MultipartFile.fromBytes(
//                   "$_filesKey[$i]",
//                   bytes,
//                   filename: fileName,
//                 ));
//                 i++;
//               }
//             }
//
//             // Single file
//             else {
//               print('INSIDE SINGLE FILE');
//
//               File file = files?[_filesKey];
//               final fileName = path.basename(file.path);
//               final bytes = await compute(
//                 UniversalFunctions.compressFileToBytes,
//                 file,
//               );
//               request.files.add(http.MultipartFile.fromBytes(
//                 _filesKey,
//                 bytes,
//                 filename: fileName,
//               ));
//             }
//           }
//
//           print('request body: ${request.fields}');
//
//           response = await request.send();
//           responseBody = await response.stream.bytesToString();
//           _isMultipartResponse = true;
//
//           print('response: ${responseBody}');
//
//           break;
//       }
//
//       responseBody =
//           jsonDecode(_isMultipartResponse ? responseBody : response.body);
//
//       print("responseBody : ${jsonEncode(responseBody)} ");
//       print("response.statusCode : ${response.statusCode} ");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map successResponseBody = responseBody;
//         completer.complete(successResponseBody);
//       } else {
//         APIError apiError = APIError(
//           error: responseBody["message"] ?? "Something went wrong",
//           responseBody: responseBody,
//           statusCode: response.statusCode,
//         );
//         completer.complete(apiError);
//       }
//     } on FormatException {
//       APIError apiError = APIError(error: "Bad format exception");
//       completer.complete(apiError);
//     } on TimeoutException {
//       APIError apiError = APIError(error: "Connection Timeout");
//       completer.complete(apiError);
//     } catch (e) {
//       print("e: $e");
//       APIError apiError = APIError(error: "Something went wrong");
//       completer.complete(apiError);
//     }
//     return completer.future;
//   }
// }
