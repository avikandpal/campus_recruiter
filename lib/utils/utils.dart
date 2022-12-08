import 'package:flutter/material.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:intl/intl.dart';

Color appColor = const Color(0xff80B7FC);

class Utils {
  static final Utils _singleton = Utils._internal();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();

  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static String? validateEmail(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        // The form is empty
        return "Please enter your registered E-mail.";
      }
      // This is just a regular expression for email addresses
      String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
          "\\@" +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
          "(" +
          "\\." +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
          ")+";
      RegExp regExp = RegExp(p);

      if (regExp.hasMatch(value)) {
        // So, the email is valid
        return null;
      }
    }

    // The pattern of the email didn't match the regex above.
    return 'Please enter a valid E-mail.';
  }

  static String stringDateInFormat(String dateFormat, DateTime dateTime) {
    var formatter = DateFormat(dateFormat);
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static DateTime convertDateFromString(String? strDate, String? utcformat) {
    DateFormat utcDateFormat = DateFormat(utcformat);
    DateTime utcDate = utcDateFormat.parse(strDate ?? "-", true);
    return utcDate;
  }
}

class CustomButton extends StatelessWidget {
  String? title;
  Color? color;
  double? height;

  CustomButton({this.title, this.color, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      height: height,
      child: Text(title ?? ""),
    );
  }
}

class RoundedActionButton extends StatefulWidget {
  //Properties
  String title;
  Color titleColor;
  Color backgroundColor;
  double height;
  double padding; //this will include the leading, trailing space
  Function()? onClick;
  double fontSize;
  FontWeight fontWeight;
  bool isEnabled;

  //Initializer
  RoundedActionButton({
    required this.title,
    required this.fontSize,
    required this.onClick,
    this.titleColor = Colors.white,
    this.backgroundColor = appThemeColor,
    this.height = 50.0,
    this.padding = 20.0,
    this.fontWeight = FontWeight.w500,
    this.isEnabled = true,
  });

  @override
  _RoundedActionButtonState createState() => _RoundedActionButtonState();
}

class _RoundedActionButtonState extends State<RoundedActionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.height,
      width: Utils.getScreenSize(context).width - 2 * widget.padding,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(widget.backgroundColor),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(widget.height / 2)),
              ),
            )),
        // disabledColor: appThemeColor.withOpacity(0.5),
        onPressed: widget.isEnabled ? widget.onClick : null,
        child: Text(
          widget.title,
          style: TextStyle(
            color: widget.titleColor,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
          ),
        ),
      ),
    );
  }
}
