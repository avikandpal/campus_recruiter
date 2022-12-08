import 'package:flutter/material.dart';
import 'package:flutter_geek_test/utils/reusable_widgets/CustomPageViewWithPageControlDots.dart';

class TestTutorials extends StatefulWidget {
  @override
  _TutorialsState createState() => _TutorialsState();
}

class _TutorialsState extends State<TestTutorials> {
  // UI properties
  Size? screenSize;
  double? _pageOffset = 0.0;

  // Returns background image
  get getBGImage {
    int page = _pageOffset?.toInt() ?? 0;
    double tutOneOpacity = 0.0;
    double tutTwoOpacity = 0.0;
    double tutThreeOpacity = 0.0;
    double opacityFactor = (_pageOffset ?? 0.0) - page;
    switch (page) {
      case 0:
        tutOneOpacity = 1.0;
        tutTwoOpacity = 0.0;
        tutThreeOpacity = 0.0;
        tutOneOpacity -= opacityFactor;
        tutTwoOpacity += opacityFactor;
        break;
      case 1:
        tutOneOpacity = 0.0;
        tutTwoOpacity = 1.0;
        tutThreeOpacity = 0.0;
        tutTwoOpacity -= opacityFactor;
        tutThreeOpacity += opacityFactor;
        break;
      case 2:
        tutOneOpacity = 0.0;
        tutTwoOpacity = 0.0;
        tutThreeOpacity = 1.0;
        tutTwoOpacity -= opacityFactor;
        tutThreeOpacity += opacityFactor;
        break;
      default:
        print("DEFAULT");
        break;
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: tutThreeOpacity,
            child: Image.asset(
              "images/welcome-top.png",
              fit: BoxFit.cover,
              height: 150,
              width: screenSize?.width,
            ),
          ),
          Opacity(
            opacity: tutTwoOpacity,
            child: Image.asset(
              "images/welcome-top.png",
              fit: BoxFit.cover,
              height: 150,
              width: screenSize?.width,
            ),
          ),
          Opacity(
            opacity: tutOneOpacity,
            child: Image.asset(
              "images/welcome-top.png",
              fit: BoxFit.cover,
              height: 150,
              width: screenSize?.width,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: screenSize?.height,
            width: screenSize?.width,
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                getBGImage,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.only(top: 120.0),
//                      child: Image.asset(
//                        "images/logo.png",
//                      height: 90.0,
//                        width: screenSize.width,
////                        height: screenSize.height * 0.12,
////                        width: screenSize.height * 0.35,
//                        fit: BoxFit.fill,
//                      ),
//                    ),
                    Center(
                      child: Container(
                        height: (screenSize?.height ?? 0) * 0.40,
                        width: screenSize?.width,
                        child: CustomPageViewWithPageControlDots(
                          pageContent: <Widget>[
                            Container(),
                            Container(),
                            Container(),
                          ],
                          pageControlDotShape: BoxShape.circle,
                          pageControlDotColorSelected: Colors.yellow,
                          onPageChanged: (double? pageOffset) {
                            setState(() {
                              _pageOffset = pageOffset ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
