import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_geek_test/ui/Login.dart';
import 'package:flutter_geek_test/ui/overview.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/utils.dart';

class Congratulations extends StatefulWidget {
  @override
  _CongratulationsState createState() => _CongratulationsState();
}

class _CongratulationsState extends State<Congratulations> {

  late Timer _timer;
  final _duration = Duration(seconds: 5);
  late Size _size;

  @override
  void initState() {
    super.initState();
    startTimer();
  }
  @override
  void didChangeDependencies() {
    _size = Utils.getScreenSize(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //MARK:-Private Functions.
  //MARK:-Function to manage User Redirection.
  void startTimer() async {
    _timer = Timer(_duration, () {
      clearLocalData();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Login();
          }), (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: _size.height,
        width: _size.width,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "Congratulations!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Your test has been submitted\nsuccessfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Image.asset(
                "images/finish-thumb.png",
                height: _size.width * 0.60,
                width: _size.width * 0.60,
              ),
              Text(
                "You will be notified about your\nresult soon",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
