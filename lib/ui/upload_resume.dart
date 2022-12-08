import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/ui/Home/home.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/manager/file_picker_manager.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';

class UploadResumeScreenArguments {
  final User? user;
  final bool isLoggedIn;

  UploadResumeScreenArguments(this.user, this.isLoggedIn);
}

class UploadResume extends StatefulWidget {
  final User? user;
  final bool isSignUp;

  UploadResume(this.user, this.isSignUp);

  @override
  _UploadResumeState createState() => _UploadResumeState();
}

class _UploadResumeState extends State<UploadResume> {
  // void _getFilePath() async {
  //   try {
  //     FilePickerResult? filePickerResult =
  //         await FilePicker.platform.pickFiles();
  //     if (filePickerResult == null) {
  //       return;
  //     }
  //     String filePath = filePickerResult.files.first.path ?? "";
  //     if (filePath.contains('docx') ||
  //         filePath.contains('pdf') ||
  //         filePath.contains('rtf')) {
  //       final File file = await File('$filePath').create();
  //       if (file.lengthSync() < 2 * 1024 * 1024) {
  //         showLoader(context, "");
  //         final Reference storageRef = FirebaseStorage.instance
  //             .ref()
  //             .child('Resume')
  //             .child('${widget.user?.sId}');
  //         final UploadTask task = storageRef.putFile(file);
  //         task.snapshotEvents.listen((event) {}).onError((error) {
  //           hideLoader(() {
  //             Navigator.pop(context);
  //           });
  //         });
  //         await task.whenComplete(() async {
  //           String downloadUrl = await storageRef.getDownloadURL();
  //           await _updateUserResumeAPI(downloadUrl);
  //         });
  //       } else {
  //         showAlert(context, 'File size should not be greater than 2mb.', () {
  //           Navigator.pop(context);
  //         }, isFail: true);
  //       }
  //     } else {
  //       showAlert(context,
  //           'Invalid file format, please upload a .pdf, .rtf or .docx file.',
  //           () {
  //         Navigator.pop(context);
  //       }, isFail: true);
  //     }
  //   } catch (e) {
  //     print("Error while picking the file: " + e.toString());
  //   }
  // }

  void _getFilePath() async {
    try {
      File? filePickerResult = await FilePickerManager.pickCustomFile(context);
      print("File Picker Result :::: $filePickerResult");
      if (filePickerResult == null) {
        return;
      }
      String filePath = filePickerResult.path ?? "";
      if (filePath.contains('docx') ||
          filePath.contains('pdf') ||
          filePath.contains('rtf')) {
        final File file = await File('$filePath').create();
        if (file.lengthSync() < 2 * 1024 * 1024) {
          String? json = await ApiHandler.uploadUserResume(file);
          var jsonData = jsonDecode(json ?? "-");
          if (jsonData['status'] == 1) {
            await showAlert(
              context,
              "Your CV has been uploaded successfully.",
              () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteList.home, (route) => false);
              },
              isWarning: false,
            );
          }
        } else {
          showAlert(context, 'File size should not be greater than 2mb.', () {
            Navigator.pop(context);
          }, isFail: true);
        }
      } else {
        showAlert(context,
            'Invalid file format, please upload a .pdf, .rtf or .docx file.',
            () {
          Navigator.pop(context);
        }, isFail: true);
      }
    } catch (e, st) {
      print("Error While Picking File ::: $e");
      // print("Error Steps While Updating Resume ::: $st");
    }
  }

  //MARK:- This method is used to upload user resume to the server
  // _updateUserResumeAPI(String? url) async {
  //   Map<String, String> requestBody = {
  //     "cv": url ?? "-",
  //   };
  //   await checkInternet((value) async {
  //     if (value) {
  //       await ApiHandler.put(requestBody, ApiHandler.cv, context,
  //           (response) async {
  //         await showAlert(
  //           context,
  //           response["message"],
  //           () {
  //             Navigator.pop(context);
  //             Navigator.pushAndRemoveUntil(context,
  //                 MaterialPageRoute(builder: (BuildContext context) {
  //               return Home();
  //             }), (Route<dynamic> route) => false);
  //           },
  //           isWarning: false,
  //         );
  //       });
  //     } else {
  //       showAlert(context, AppMessage.noInternetMessage, () {
  //         Navigator.pop(context);
  //       }, isWarning: true);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload Resume",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appThemeColor,
        leading: BackButton(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacers.height50px,
            CircleAvatar(
              child: Image.asset("images/profile-cv-upload.png"),
              radius: 90,
              backgroundColor: Colors.transparent,
            ),
            Spacers.height20px,
            Text(
              "Please upload file less than 2mb in\n .docx, .rtf and .pdf format",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Spacers.height80px,
            RoundedActionButton(
              title: "Upload Resume",
              fontSize: 18,
              onClick: () {
                _getFilePath();
              },
              fontWeight: FontWeight.w500,
              padding: 70.0,
              height: 45.0,
            ),
            (widget.isSignUp)
                ? TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RouteList.home, (route) => false);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width / 2,
                      height: 20,
                      child: Text(
                        "Skip & Continue",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)))),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
