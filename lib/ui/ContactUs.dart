import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';

import '../network/apis.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  FocusNode _emailField = FocusNode();
  FocusNode _subjectField = FocusNode();
  FocusNode _messageField = FocusNode();

  GlobalKey<FormState> _contactUsFormKey = GlobalKey();

  String get email => _emailController.text;

  String get subject => _subjectController.text;

  String get comment => _commentController.text;

  double? _keyBoardSize;

  late Size _size;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _size = Utils.getScreenSize(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    _keyBoardSize = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              color: Colors.white,
            ),
            backgroundColor: appThemeColor,
            centerTitle: true,
            title: Text(
              "Contact Us",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: Paddings.horizontal32px,
            child: SingleChildScrollView(
              child: Container(
                height: (_size.height) -
                    AppBar().preferredSize.height -
                    statusBarHeight +
                    6.5,
                child: Form(
                  key: _contactUsFormKey,
                  child: Column(
                    children: <Widget>[
                      Spacers.height20px,
                      Image.asset(
                        'images/logo.png',
                        height: 150.0,
                        width: 150.0,
                      ),
                      Spacers.height10px,
                      TextFormField(
                        controller: _emailController,
                        validator: (val) => Utils.validateEmail(val),
                        focusNode: _emailField,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: "Email",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_subjectField);
                        },
                      ),
                      Spacers.height16px,
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        controller: _subjectController,
                        validator: _validateSubject,
                        focusNode: _subjectField,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: "Subject",
                            hintStyle: TextStyle(color: Colors.grey)),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_messageField);
                        },
                      ),
                      Spacers.height16px,
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1000),
                        ],
                        validator: _validateMessage,
                        controller: _commentController,
                        focusNode: _messageField,
                        maxLines: null,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: "Concern",
                            hintStyle: TextStyle(color: Colors.grey)),
                        textAlign: TextAlign.start,
                      ),
                      Spacers.height30px,
                      RoundedActionButton(
                        title: "Submit",
                        fontSize:20,
                        onClick: () {
                          if (_contactUsFormKey.currentState?.validate() ??
                              false) {
                            _submit();
                          }
                        },
                        fontWeight: FontWeight.w500,
                        padding: 60.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  String? _validateSubject(String? value) {
    if (value != null && value.isEmpty) {
      return "Please enter a subject.";
    } else if ((value?.length ?? 0) >= 100) {}
    return null;
  }

  String? _validateMessage(String? value) {
    if (value != null && value.isEmpty) {
      return "Please enter a concern.";
    } else if ((value?.length ?? 0) >= 1000) {}
    return null;
  }

  _submit() async {
    showLoader(context, "");
    print(_emailController.text);
    print(_subjectController.text);
    print(_commentController.text);
    Map<String, String> requestBody = {
      "email": _emailController.text,
      "subject": _subjectController.text,
      "query": _commentController.text
    };
    ApiHandler.post(requestBody, ApiNames.help, context, (response) {
      if (response["status"] == 1) {
        showAlert(context, response["message"], () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    });
  }
}
