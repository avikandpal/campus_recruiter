import 'package:flutter/material.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';

class WelcomeStudentWidget extends StatefulWidget {
  //Properties
  final String? name;

  //Initializer
  WelcomeStudentWidget({required this.name});

  @override
  _WelcomeStudentWidgetState createState() => _WelcomeStudentWidgetState();
}

class _WelcomeStudentWidgetState extends State<WelcomeStudentWidget> {
  double fontHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8),
        child: Text.rich(
          TextSpan(
              text: "Hello  ",
              style: TextStyle(fontSize: fontHeight),
              children: [
                TextSpan(
                    text: widget.name,
                    style: TextStyle(
                        color: appThemeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontHeight))
              ]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
