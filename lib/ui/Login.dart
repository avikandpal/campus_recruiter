import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geek_test/ui/ContactUs.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_ids/unique_ids.dart';

import '../network/apis.dart';
import '../utils/persistence/data/shared_prefs_keys.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Size screenSize;
  bool isHideImage = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  String? _email;
  String? errorMessage;
  TextEditingController? _emailController;

  @override
  void initState() {
    super.initState();
    getDeviceId();
    getDeviceType();
    _initPackageInfo();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController?.dispose();
    super.dispose();
  }

  //MARK:- Get device ID.
  void getDeviceId() async {
    try {
      String? uniqueID = await UniqueIds.uuid;
      print("my decvice id:-$uniqueID");

      SharedPreferences.getInstance().then((pref) {
        pref.setString(SharedPrefsKeys.deviceId, uniqueID ?? "-");
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

  Widget getEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Enter Email',
      ),
      validator: (val) => Utils.validateEmail(val),
      onSaved: (val) => _email = val,
    );
  }

  Widget getSubmitButton() {
    return RoundedActionButton(
      title: "Login",
      fontSize: 20,
      onClick: () {
        submitAction();
      },
      fontWeight: FontWeight.w500,
      padding: 60.0,
    );
  }

  void submitAction() {
    final form = formKey.currentState;
    if (form?.validate() ?? false) {
      form?.save();
      // Email & password matched our validation rules
      // and are saved to _email and _password fields.
      _performLogin();
    }
  }

  void _loginApi() {
    Map<String, String> requestBody = {
      "email": _email ?? "-",
    };
    print(requestBody);
    checkInternet((value) async {
      if (value) {
        showLoader(context, "");
        await ApiHandler.post(requestBody, ApiNames.login, context,
            (response) {
          if (response["status"] == 1) {
            clearLocalTables();
            var customMessage =
                response["message"] + "\nOtp:- ${response["data"]["otp"]}";
            showAlert(context, customMessage, () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (Otp(email: _email))));
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

  void _performLogin() {
    _loginApi();
  }

  Widget getHireMeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Welcome to',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25.0),
        ),
        Spacers.width5px,
        Text(
          'Campus Recruiter',
          style: TextStyle(
              color: appThemeColor,
              fontWeight: FontWeight.w600,
              fontSize: 25.0),
        ),
      ],
    );
  }

  //This method is used to get login form.
  Widget getLoginForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            getEmailField(),
            Spacers.height30px,
            getSubmitButton()
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    print("Pop Result =====> $result");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = Utils.getScreenSize(context);
    isHideImage = MediaQuery.of(context).viewInsets.bottom > 0.0 ? true : false;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: <Widget>[
          Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  isHideImage = false;
                });
              },
              child: Stack(
                children: <Widget>[
                  Offstage(
                    child: Image.asset(
                      'images/loginbg.png',
                      height: screenSize.height,
                      width: screenSize.width,
                      alignment: Alignment.bottomCenter,
                    ),
                    offstage: isHideImage,
                  ),
                  ListView(
                    children: <Widget>[
                      Spacers.height40px,
                      Image.asset(
                        'images/logo.png',
                        height: 150.0,
                        width: 150.0,
                      ),
                      Spacers.height30px,
                      getHireMeText(),
                      Spacers.height30px,
                      getLoginForm(),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        print("Hello");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (ContactUs()),
                          ),
                        );
                      },
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 5),
                          child: Container(
                            height: 35,
                            width: 35,
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.help,
                              size: 35,
                              color: appThemeColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
