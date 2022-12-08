import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/ui/Home/instructions.dart';
import 'package:flutter_geek_test/ui/Home/welcomeStudent.dart';
import 'package:flutter_geek_test/ui/select_category.dart';
import 'package:flutter_geek_test/ui/upload_resume.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/reusable_widgets/DotsIndicator.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/apis.dart';
import '../../utils/persistence/data/shared_prefs_keys.dart';
import '../../utils/routing/route_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String examDate = "00-00-0000";
  String examTime = "00";
  String? studentName;
  int? duration;
  // int timeDuration;
  String? serverDateString;
  int timeLeftToStart = 1;
  Timer? _timer;
  bool isTestStart = false;
  User? user;
  Timer? _timerPagingImages;

  final images = [
    "images/1.png",
    "images/2.png",
    "images/3.png",
    "images/4.png"
  ];
  var selected = 0;
  PageController? _controller;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TapGestureRecognizer? _tapGestureRecognizer;
  InternetConnectionChecker? _internetConnectionChecker;
  StreamSubscription<InternetConnectionStatus>? _connectivitySubscription;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
    _internetConnectionChecker = InternetConnectionChecker();
    checkInternetToSync();
    _getUserData();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _handleTapOnUploadResume;
    _timer = Timer.periodic(Duration(seconds: 1), _onTimeChange);
    startAutoPaging();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tapGestureRecognizer?.dispose();
    _timer?.cancel();
    _timerPagingImages?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _onTimeChange(Timer timer) {
    setState(() {
      if (timeLeftToStart > 0) {
        timeLeftToStart = timeLeftToStart - 1;
      } else {
        _timer?.cancel();
        isTestStart = true;
      }
    });
  }

  startAutoPaging() {
    _timerPagingImages = Timer.periodic(Duration(seconds: 7), (timer) {
      selected++;
      if (selected == images.length) {
        selected = 0;
      }
      _controller?.animateToPage(selected,
          duration: Duration(seconds: 1), curve: Curves.ease);
    });
  }

  Widget filterTimerWidget(int index, int remaningTime) {
    final remaining = Duration(seconds: remaningTime);
    final days = remaining.inDays;
    final hours = remaining.inHours - remaining.inDays * 24;
    final minutes = remaining.inMinutes - remaining.inHours * 60;
    final seconds = remaining.inSeconds - remaining.inMinutes * 60;
    if (remaningTime == 1 || remaningTime == 0) {
      return Text(
        '--',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
    if (index == 0) {
      return Text(
        '${days}'.padLeft(2, "0"),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else if (index == 1) {
      return Text(
        '$hours'.padLeft(2, "0"),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else if (index == 2) {
      return Text(
        '$minutes'.padLeft(2, "0"),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else if (index == 3) {
      return Text(
        '$seconds'.padLeft(2, "0"),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
    return Container();
  }

  Widget getTimerWidget(int remainingTime) {
    List daysTimeList = ["Day", "Hr", "Min", "Sec"];
    return Container(
      height: 61,
      width: 300,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemCount: daysTimeList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Text(
                  '${daysTimeList[index]}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                filterTimerWidget(index, remainingTime)
              ],
            );
          }),
    );
  }

  _getUserData() async {
    User newUser = await getUser;
    user = newUser;
    setState(() {
      studentName = newUser.name;
    });
    _getScheduleApi();
  }

  Future _instructionApi() async {
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.get("${ApiNames.instructions}", context, (response) {
          if (response["status"] == 1) {
            List data = response["data"];
            _scaffoldKey.currentState?.showBottomSheet(
              (BuildContext context) {
                return InstructionsScreen(data);
              },
            );
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

  void _getScheduleApi() async {
    var prefs = await SharedPreferences.getInstance();
    var batchID = prefs.getString(SharedPrefsKeys.batchId);
    var request = "?batch_id=$batchID";

    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.get("${ApiNames.schedule}$request", context, (response) {
          if (response["status"] == 1) {
            Map data = response["data"];
            String testTime = data["test_time"];
            //timeDuration=int.parse(data["time_left_to_end"].toString())-int.parse(data["time_left_to_start"].toString());
            timeLeftToStart = data["time_left_to_start"] ?? 0;

            duration = timeLeftToStart.isNegative
                ? data["time_left_to_end"]
                : data["time_left_to_end"] - timeLeftToStart;
            duration = (duration?.isNegative ?? false) ? 0 : duration;

            print("durtion $duration");

            serverDateString = data["utc_time"];
            var utcDate =
                Utils.convertDateFromString(testTime, 'yyyy/MM/dd HH:mm');
            setState(() {
              examDate =
                  Utils.stringDateInFormat("dd-MM-yyyy", utcDate.toLocal());
              examTime = Utils.stringDateInFormat("hh:mm a", utcDate.toLocal());
            });
          }
        });
      } else {
        showAlert(context, AppMessage.noInternetMessage, () {
          Navigator.pop(context);
        }, isWarning: true);
      }
    });
  }

  Future<bool> _onWillPop() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
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
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  _topImageView(Utils.getScreenSize(context)),
                  Spacers.height20px,
                  studentName != null
                      ? WelcomeStudentWidget(name:studentName)
                      : Container(),
                  Spacers.height20px,
                  _examDateTimeInfoWidget(),
                  Padding(
                    padding: Paddings.all5px,
                    child: !isTestStart
                        ? getTimerWidget(timeLeftToStart)
                        : Container(),
                  ),
                  Spacers.height20px,
                  _startTestButtonWidget(),
                  Spacers.height5px,
                  _readInstructionButtonWidget(),
                  _uploadResumeActionWidget()
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _handleTapOnUploadResume() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteList.uploadResume,
      (route) => false,
      arguments: UploadResumeScreenArguments(user, false),
    );
  }

  Widget _topImageView(Size size) {
    return Container(
      height: size.height * 0.40,
      width: size.width,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: images.length,
            scrollDirection: Axis.horizontal,
            controller: _controller,
            onPageChanged: (page) {
              setState(() {
                selected = page;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Image.asset(
                getImagePath(index),
                fit: BoxFit.cover,
              );
            },
          ),
          getDots()
        ],
      ),
    );
  }

  String getImagePath(int position) {
    return images[position];
  }

  getDots() {
    return DotsIndicator(
      numberOfDot: images.length,
      dotActiveColor: Colors.white,
      position: selected,
      dotColor: Colors.white30,
      dotActiveSize: const Size(10, 10),
      dotSize: const Size(10, 10),
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _examDateTimeInfoWidget() {
    return Padding(
      padding: Paddings.horizontal20px,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("images/welcome-time-bg.png"),
          Padding(
            padding: Paddings.horizontal20px,
            child: isTestStart
                ? Text(
                    "Your test has been started at $examTime, "
                    "please click on start test button to start your test.",
                    textAlign: TextAlign.center,
                  )
                : Text.rich(
                    TextSpan(
                        text: "Your Exam is on ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: examDate,
                              style: TextStyle(
                                  color: appThemeColor,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " at ",
                              style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: examTime,
                              style: TextStyle(
                                  color: appThemeColor,
                                  fontWeight: FontWeight.bold)),
                        ]),
                    textAlign: TextAlign.center,
                  ),
          )
        ],
      ),
    );
  }

  Widget _startTestButtonWidget() {
    return RoundedActionButton(
      title: "Start Test",
      fontSize: 16.0,
      onClick: () async {
        if (isTestStart) {
          var prefs = await SharedPreferences.getInstance();
          checkInternet((value) {
            if (value) {
              prefs.setBool(SharedPrefsKeys.isTestStarted, true);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteList.selectCategory,
                (route) => false,
                arguments: SelectCategoryScreenArguments(duration),
              );
            } else {
              showAlert(context, AppMessage.noInternetMessage, () {
                Navigator.pop(context);
              }, isWarning: true);
            }
          });
        }
      },
      padding: 50,
      isEnabled: isTestStart,
    );
  }

  Widget _readInstructionButtonWidget() {
    return TextButton(
        onPressed: () {
          _instructionApi();
        },
        child: Text(
          "Read Instruction",
          style: TextStyle(decoration: TextDecoration.underline),
        ));
  }

  void checkInternetToSync() {
    _connectivitySubscription = _internetConnectionChecker?.onStatusChange
        .listen((InternetConnectionStatus internetConnectionStatus) {
      if (internetConnectionStatus == InternetConnectionStatus.connected) {
        _getScheduleApi();
      }
    });

    //     _internetConnectionChecker?.onStatusChange.listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.wifi ||
    //       result == ConnectivityResult.mobile) {
    //     _getScheduleApi();
    //   }
    // });
  }

  Widget _uploadResumeActionWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20.0),
      child: Text.rich(
        TextSpan(
            text:
                "Before your test starts, you can upload resume clicking on the ",
            style: TextStyle(
              fontSize: 12.0,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: "Upload Resume",
                  style: TextStyle(
                      color: appThemeColor,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline),
                  recognizer: _tapGestureRecognizer),
              TextSpan(text: " option.")
            ]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
