import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_geek_test/ui/Login.dart';
import 'package:flutter_geek_test/utils/app_theme.dart';
import 'package:flutter_geek_test/utils/reusable_widgets/DotsIndicator.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';

import '../utils/routing/route_list.dart';

class Tutorials extends StatefulWidget {
  const Tutorials({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Tutorials> {
  PageController? _controller;
  var selected = 0;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        print("TUTORIALS BACK PRESSED");
        exit(0);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            PageView.builder(
              itemCount: tutorialTextTitles.length,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _controller,
              onPageChanged: (page) {
                setState(() {
                  selected = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return getPage(size, tutorialTextTitles[index], index);
              },
            ),
            Positioned(
              left: 0,
              bottom: 80,
              right: 0,
              child: DotsIndicator(
                numberOfDot: tutorialTextTitles.length,
                dotActiveColor: Colors.blue,
                position: selected,
                dotColor: Colors.blue[50],
                dotActiveSize: const Size(13, 13),
                dotSize: const Size(13, 13),
                alignment: Alignment.center,
              ),
            ),
            Positioned(
              right: 18,
              child: Material(
                color: Colors.blue,
                borderRadius: AppTheme.appBorderRadius,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RouteList.login, (route) => false);
                  },
                  borderRadius: AppTheme.appBorderRadius,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                    child: Text(
                      selected == tutorialText.length - 1 ? "Login" : "Skip",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              bottom: 16,
            )
          ],
        ),
      ),
    );
  }

  var tutorialTextTitles = [
    "Easy Login",
    "Easy switch to any Question",
    "Easy to filter Questions"
  ];
  var tutorialText = [
    "Welcome to Campus Recruiter! To begin, please log in by entering your email address. An OTP will be sent to the email through which you can proceed to the next step",
    "You can easily switch to any question of your choice with one simple click. To do so, simply browse through the list of questions therein",
    "You can easily filter questions based on category, topic, question type, keyword, etc."
  ];

  String getImagePath(int position) {
    String path = "images/one.png";
    switch (position) {
      case 0:
        path = "images/one.png";
        break;
      case 1:
        path = "images/two.png";
        break;
      case 2:
        path = "images/three.png";
        break;
    }
    return path;
  }

  getPage(Size screenSize, String text, int index) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Image.asset(getImagePath(index)),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 32,
              ),
              Text(
                text,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: Paddings.all16px,
                child: Text(
                  tutorialText[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
