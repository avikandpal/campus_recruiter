import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/ui/Home/welcomeStudent.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';

class InstructionsScreenArguments {
  final List instructionList;

  InstructionsScreenArguments(this.instructionList);
}

class InstructionsScreen extends StatefulWidget {
  List instructionList;

  InstructionsScreen(this.instructionList);

  @override
  _InstructionsScreenState createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  var instructionsCount = 100;
  String? studentName;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  _getUserData() async {
    User? user = await getUser;
    setState(() {
      studentName = user?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  offset: Offset(1.0, 1.0),
                  spreadRadius: 5.0,
                  blurRadius: 3.0),
            ]),
        child: Column(
          children: <Widget>[
            _headerViewWidget(),
            Expanded(child: _listView()),
//            Padding(
//              padding: const EdgeInsets.only(
//                  left: 40.0, right: 40.0, bottom: 20.0, top: 20.0),
//              child: RoundedActionButton(
//                "Start Test",
//                15.0,
//                () {
//                  Navigator.of(context).pop();
//                },
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _instructionRowWidget(index);
        },
        itemCount: widget.instructionList.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _instructionRowWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${index + 1}. ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              "${widget.instructionList[index]}",
              textAlign: TextAlign.left,
            ),
          )
        ],
      ),
    );
  }

  Widget _headerViewWidget() {
    return Column(
      children: <Widget>[
        Spacers.height10px,
        Stack(
          children: <Widget>[
            Center(
              child: studentName != null
                  ? WelcomeStudentWidget(name:studentName)
                  : Container(),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'images/cross.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
        Spacers.height10px,
        _readInstructionsWidget(),
      ],
    );
  }

  Widget _readInstructionsWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 25.0, top: 8.0, bottom: 8.0),
          child: Text(
            "Read the Instructions Carefully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
