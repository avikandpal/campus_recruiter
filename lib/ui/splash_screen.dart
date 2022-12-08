import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geek_test/model/Category.dart';
import 'package:flutter_geek_test/ui/Home/home.dart';
import 'package:flutter_geek_test/ui/Tutorials.dart';
import 'package:flutter_geek_test/ui/question_list.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_ids/unique_ids.dart';

import '../network/apis.dart';
import '../utils/persistence/data/shared_prefs_keys.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  //MARK:- Variables..
  bool? isUserLoggedIn = false;
  bool hideButton = true;
  final _duration = Duration(seconds: 3);
  String _companyName = "";
  Timer? _timer;
  List<Category> categoryList = [];
  // late AnimationController animationController;
  bool isInternetAvailable = true;
  late Size _size;

  @override
  void initState() {
    super.initState();
    checkUserLoggedInOrNot();
    // animationController =
    //     AnimationController(vsync: this, duration: Duration(seconds: 3));
    // animationController.repeat();
  }

  @override
  void didChangeDependencies() {
    _size = Utils.getScreenSize(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  //MARK:-Functions to Get Scaffold Widgets..
  //MARK:- Get Logo Widget.
  get _getLogo {
    return

        // AnimatedBuilder(
        // animation: animationController,
        // child:
        Image.asset(
      'images/logo.png',
      height: _size.width * 0.4,
      width: _size.width * 0.4,
    )
        //     , builder: (BuildContext? context, Widget? _widget) {
        //     return Transform.scale(
        //       scale: animationController.value * 1.5,
        //       child: _widget,
        //     );
        //   },
        // )
        ;
  }

  //MARK:-Private Functions.
  //MARK:-Function to manage User Redirection.
  void startTimer() async {
    _timer = Timer(_duration, () {
      SharedPreferences.getInstance().then((pref) {
        isUserLoggedIn = pref.getBool(SharedPrefsKeys.isLoggedIn);
        var isTestStart = pref.getBool(SharedPrefsKeys.isTestStarted);

        // bool? isTimesUp = pref.getBool(SharedPrefsKeys.isTimeOut);
        bool? isTimesUp = false;

        if (isTimesUp != null && isTimesUp) {
          showTimeUpDialog(context, () async {
            filterQuestionAndSyncToServer(context);
          });
          return;
        } else {
          if (isUserLoggedIn != null) {
            //Redirect on dashboard screen
            if (isTestStart != null && isTestStart) {
              _getCategoryListApi();
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, RouteList.home, (route) => false);
            }
          } else {
            //Redirect on login screen
            Navigator.pushNamedAndRemoveUntil(
                context, RouteList.tutorials, (route) => false);
          }
        }
      });
    });
  }

  void _getScheduleApi() async {
    var prefs = await SharedPreferences.getInstance();
    var batchID = prefs.getString(SharedPrefsKeys.batchId);

    checkInternet((value) {
      if (value) {
        var request = "?batch_id=$batchID";
        ApiHandler.get("${ApiNames.schedule}$request", context, (response) {
          if (response["status"] == 1) {
            Map data = response["data"];
            int timeLeftToEnd = data["time_left_to_end"];
            print("Time Left To End :::: $timeLeftToEnd");
            var subCategoryList = categoryList.first.subCategory;
            print("Categories ${categoryList.length}");
            print("Sub Categories ${subCategoryList?.length}");
            if (subCategoryList?.isNotEmpty ?? false) {
              navigateToQuestionScreen(
                index: 0,
                subCategory: subCategoryList?.first,
                duration: timeLeftToEnd,
              );
            } else {
              navigateToQuestionScreen(
                index: 0,
                subCategory: null,
                duration: timeLeftToEnd,
              );
            }
          }
        }, hideLoaderState: false);
      } else {
        showAlert(context, AppMessage.noInternetMessage, () {
          Navigator.pop(context);
        }, isWarning: true);
        return;
      }
    });
  }

  void _getCategoryListApi() {
    checkInternet((value) {
      if (value) {
        setState(() {
          isInternetAvailable = true;
        });
        ApiHandler.get(ApiNames.category, context, (response) {
          if (response["status"] == 1) {
            setState(() {
              setCategoryList(response["data"]);
              _getScheduleApi();
            });
          }
        }, hideLoaderState: false);
      } else {
        setState(() {
          isInternetAvailable = false;
        });
//        showAlert(context, AppMessage.noInternetMessage, () {
//          Navigator.pop(context);
//        }, isWarning: true);
//        return null;
      }
    });
  }

  void setCategoryList(List data) async {
    categoryList = [];
    data.forEach((v) {
      categoryList.add(Category.fromJson(v));
    });
  }

  navigateToQuestionScreen(
      {required int index,
      required SubCategory? subCategory,
      required int duration}) async {
    Category obj = categoryList[index];
    var subCategoryIndex =
        subCategory == null ? -1 : obj.subCategory?.indexOf(subCategory);
    String? selectedID = "";
    if (subCategory != null) {
      selectedID = subCategory.sId;
      obj.subCategory?.forEach((subcategory) => subCategory.isSelected = false);
      subCategory.isSelected = true;
    } else {
      selectedID = obj.sId;
    }
    categoryList.forEach((catgeory) => catgeory.isSelected = false);
    obj.isSelected = true;
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      RouteList.questionList,
      (route) => false,
      arguments: QuestionListScreenArguments(
        categoryList: categoryList,
        subCategoryList: obj.subCategory,
        selectedCategoryId: selectedID,
        categoryIndex: index,
        subCategoryIndex: (subCategoryIndex ?? 0),
        duration: duration,
      ),
    );
  }

  //MARK:- Get device ID.
  void getDeviceId() async {
    try {
      String? uniqueID = await UniqueIds.uuid;
      SharedPreferences.getInstance().then((pref) {
        pref.setString(SharedPrefsKeys.deviceId, (uniqueID ?? "-"));
      });
    } on PlatformException {}
  }

  //MARK:-Get Device Type.
  void getDeviceType() async {
    var deviceType = "2";
    if (Platform.isIOS) {
      deviceType = "2";
    } else if (Platform.isAndroid) {
      deviceType = "1";
    }
    SharedPreferences.getInstance().then((pref) {
      pref.setString(SharedPrefsKeys.deviceType, deviceType);
    });
  }

  //MARK:-Get PackageInfo
  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    var appVersion = info.version;
    SharedPreferences.getInstance().then((pref) {
      pref.setString(SharedPrefsKeys.appVersion, appVersion);
    });
  }

  void checkUserLoggedInOrNot() async {
    SharedPreferences.getInstance().then((pref) {
      var token = pref.get(SharedPrefsKeys.token);
      startTimer();
      if (token != null) {
        setState(() {});
      } else {
        getDeviceType();
        getDeviceId();
        _initPackageInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: _getLogo,
          ),
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Offstage(
                offstage: isInternetAvailable,
                child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Please connect to internet.'),
                      Spacers.height10px,
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40 / 2)),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(appThemeColor),
                            ),
                            onPressed: () {
                              _getCategoryListApi();
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Try Again',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
