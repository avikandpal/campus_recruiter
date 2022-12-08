import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/model/question_model.dart';
import 'package:flutter_geek_test/ui/Login.dart';
import 'package:flutter_geek_test/ui/congratulations.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/manager/database_manager.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/persistence/data/shared_prefs_keys.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/apis.dart';
import 'reusable_widgets/SpinKitThreeBounce.dart';

List<Map<String, dynamic>?>? submitResultJsonArray = [];

void clearLocalData() async {
  var prefs = await SharedPreferences.getInstance();
  prefs.clear();
  var dataBaseHelper = DatabaseManager();
  await dataBaseHelper.deleteAllQuestionsAndAnswer();
}

void clearLocalTables() async {
  var dataBaseHelper = DatabaseManager();
  await dataBaseHelper.deleteAllQuestionsAndAnswer();
}

void clearUserData(BuildContext context) async {
  SharedPreferences? prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString(SharedPrefsKeys.deviceId);
  String? deviceType = prefs.getString(SharedPrefsKeys.deviceType);
  String? appVersion = prefs.getString(SharedPrefsKeys.appVersion);
  prefs.clear();
  prefs.setBool(SharedPrefsKeys.isLoggedIn, false);
  prefs.setString(SharedPrefsKeys.deviceId, (deviceId ?? ""));
  prefs.setString(SharedPrefsKeys.deviceType, (deviceType ?? ""));
  prefs.setString(SharedPrefsKeys.appVersion, (appVersion ?? ""));
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (BuildContext context) {
    return Login();
  }), (Route<dynamic> route) => false);
}

showAlert(BuildContext context, String message, VoidCallback callback,
    {bool isFail = false, bool isWarning = false, String actionTitle = "OK"}) {
  var cupertinoAlert = CupertinoAlertDialog(
    content: Column(
      children: <Widget>[
        largeSpacer16dp,
        Text(
          message,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    ),
    title: Icon(
      isWarning
          ? Icons.warning
          : isFail
              ? Icons.error
              : Icons.check_circle,
      size: 46.0,
      color: isWarning
          ? Colors.amber
          : isFail
              ? Colors.red
              : appThemeColor,
    ),
    actions: <Widget>[
      CupertinoDialogAction(
        child: Text(actionTitle, style: TextStyle(color: appThemeColor)),
        onPressed: callback,
        isDefaultAction: true,
      ),
    ],
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return cupertinoAlert;
      },
      barrierDismissible: false);
}

showAlertWithTwoButton(BuildContext context, String message, Icon icon,
    VoidCallback callback, VoidCallback cancelCallback,
    {bool isFail = false,
    bool isWarning = false,
    String actionTitle = "OK",
    String cancelActionTitle = "Cancel"}) {
  var cupertinoAlert = CupertinoAlertDialog(
    content: Column(
      children: <Widget>[
        largeSpacer16dp,
        Text(
          message,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    ),
    title: icon,
    actions: <Widget>[
      CupertinoDialogAction(
        child: Text(actionTitle, style: TextStyle(color: appThemeColor)),
        onPressed: callback,
        isDefaultAction: true,
      ),
      CupertinoDialogAction(
        child: Text(cancelActionTitle, style: TextStyle(color: appThemeColor)),
        onPressed: cancelCallback,
        isDefaultAction: true,
      ),
    ],
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return cupertinoAlert;
      },
      barrierDismissible: false);
}

// Show alert dialog
void showAlertWithChoiceButtons({
  required BuildContext context,
  String? titleText,
  Widget? title,
  String? message,
  Widget? content,
  Map<String, VoidCallback>? actionCallbacks,
}) {
  Widget titleWidget = titleText == null
      ? title ?? Container()
      : Text(titleText.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ));
  Widget contentWidget = message == null
      ? content ?? Container()
      : Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.0),
        );

  OverlayEntry? alertDialog;
  // Returns alert actions
  List<Widget> _getAlertActions(Map<String, VoidCallback> actionCallbacks) {
    List<Widget> actions = [];
    actionCallbacks.forEach(
      (String title, VoidCallback action) {
        actions.add(
          ButtonTheme(
            minWidth: 0.0,
            child: CupertinoDialogAction(
              child: Text(
                title,
                style: TextStyle(
                  // color: dialogContentColor,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () {
                action();
                alertDialog?.remove();
                // alertAlreadyActive = false;
              },
            ),
          ),
        );
      },
    );
    return actions;
  }
}

Widget get largeSpacer16dp {
  return const SizedBox(
    height: 16.0,
    width: 16.0,
  );
}

Widget get medium8dp {
  return const SizedBox(
    height: 8.0,
    width: 8.0,
  );
}

Size getScreenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

//MARK:-Show Loader.
showLoader(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return SpinKitThreeBounce(
        color: appThemeColor,
        size: 30.0,
      );
    },
  );
}

//MARK:-Hide Loader.
hideLoader(VoidCallback callback) {
  callback();
}

//MARK:- This Function will check the internet connection.....
checkInternet(Function(bool)? callback) async {
  bool _hasInternet = await InternetConnectionChecker().hasConnection;
  print("Has Connection ::: $_hasInternet");
  (callback ?? (bool val) {})(_hasInternet);
}

//MARK:-Get User.
get getUser async {
  SharedPreferences? pref = await SharedPreferences.getInstance();
  String? userString = pref.getString(SharedPrefsKeys.user);
  var userJson = json.decode(userString ?? "");
  User? user = User.fromJson(userJson);
  return user;
}

showTimeUpDialog(BuildContext context, VoidCallback callback) {
  var alert = CupertinoAlertDialog(
    content: Column(
      children: <Widget>[
        Image.asset(
          "images/time-up-clock.png",
          height: 84,
          width: 84,
        ),
        medium8dp,
        Text(
          "Time is up!",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        medium8dp,
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(appThemeColor),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // splashColor: const Color.fromRGBO(231, 172, 89, 1),
          onPressed: callback,
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    ),
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: false);
}

filterQuestionAndSyncToServer(BuildContext context) async {
  var dataBaseHelper = DatabaseManager();
  List<Question?>? questionList = await dataBaseHelper.getQuestionList();
  List<Answer?>? answerList = await dataBaseHelper.getAnswerList();
  List<Question?>? filteredQuestionList = [];
  submitResultJsonArray = [];

  filteredQuestionList = questionList?.where((question) {
    question?.answerList = answerList?.where((answer) {
      return answer?.questionId == question.questionId;
    }).toList();
    return true;
  }).toList();

  filteredQuestionList?.where((question) {
    var filteredAnswerList =
        question?.answerList?.where((answer) => answer?.answered == 1).toList();
    if ((filteredAnswerList?.length ?? 0) > 0) {
      setUpQuestionData(question, filteredAnswerList?.first);
      return true;
    }
    return false;
  }).toList();
  questionSyncToLocal(submitResultJsonArray, context);
}

setUpQuestionData(Question? question, Answer? answer) {
  Map<String, dynamic> filteredResult = {
    "category_id": question?.categoryId,
    "question_id": question?.questionId,
    "is_correct": answer?.isCorrect,
    "answer": [answer?.id]
  };
  if (question?.subCategoryId?.isNotEmpty ?? false) {
    filteredResult["sub_category_id"] = question?.subCategoryId;
  }
  submitResultJsonArray?.add(filteredResult);
}

questionSyncToLocal(
    List<Map<String, dynamic>?>? result, BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  var quizId = prefs.getString(SharedPrefsKeys.quizId);
  print('questionSyncToLocal');
  print(quizId);
  Map<String, dynamic> requestBody = {"quiz_id": quizId, "data": result};
  checkInternet((value) {
    if (value) {
      showLoader(context, "");
      ApiHandler.post(requestBody, ApiNames.syncQuestion, context, (response) {
        print("Sync  result $response");
        if (response["status"] == 1) {
          completeTestAPI(context, quizId);
        }
      });
    } else {
      showAlert(context, AppMessage.noInternetMessage, () {
        Navigator.pop(context);
      }, isWarning: true);
      return;
    }
  });
}

completeTestAPI(BuildContext context, String? quizId) async {
  Map<String, dynamic> requestBody = {"quiz_id": quizId};
  checkInternet((value) {
    if (value) {
      showLoader(context, "");
      ApiHandler.put(requestBody, ApiNames.submitTest, context, (response) {
        if (response["status"] == 1) {
          clearLocalData();

          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return Congratulations();
          }), (Route<dynamic> route) => false);
        }
      });
    } else {
      showAlert(context, AppMessage.noInternetMessage, () {
        Navigator.pop(context);
      }, isWarning: true);
      return;
    }
  });
}

disqualifyUser(BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  var quizId = prefs.getString(SharedPrefsKeys.quizId);
  Map<String, dynamic> requestBody = {"quiz_id": quizId};
  checkInternet((value) {
    if (value) {
      showLoader(context, "");
      ApiHandler.put(requestBody, ApiNames.invalidTest, context, (response) {
        if (response["status"] == 1) {
          clearLocalData();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return Login();
          }), (Route<dynamic> route) => false);
        }
      });
    } else {
      showAlert(context, AppMessage.noInternetMessage, () {
        Navigator.pop(context);
      }, isWarning: true);
      return;
    }
  });
}

Future<bool> onWillPop(BuildContext context) async {
  bool result = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Are you sure?'),
      content: Text(
          'You can Open/close the App maximum of 3 times, After that your test will be suspended. Do you want to exit an App.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes'),
        ),
      ],
    ),
  );
  return result;
}

// Checks target platform
bool isAndroid() {
  return defaultTargetPlatform == TargetPlatform.android;
}
