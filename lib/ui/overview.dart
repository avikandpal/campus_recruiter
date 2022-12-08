import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/Category.dart';
import 'package:flutter_geek_test/model/question_model.dart';
import 'package:flutter_geek_test/ui/otp.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/manager/database_manager.dart';
import 'package:flutter_geek_test/utils/reusable_widgets/circular_percent_indicator.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';

class Result {
  int answer, totalQuestion;

  Result(this.answer, this.totalQuestion);
}

class OverViewScreenArguments {
  final List<Category>? categoryList;
  final Duration timerDuration;
  final Function onFilterApplied;

  OverViewScreenArguments({
    required this.categoryList,
    required this.timerDuration,
    required this.onFilterApplied,
  });
}

class Overview extends StatefulWidget {
  List<Category>? categoryList = [];
  Duration timerDuration;
  final Function onFilterApplied;

  Overview({
    required this.categoryList,
    required this.timerDuration,
    required this.onFilterApplied,
  });

  @override
  OverviewState createState() {
    return OverviewState();
  }
}

class OverviewState extends State<Overview>
    with SingleTickerProviderStateMixin {
  final circleWidth = 16.0;

  final circleRadius = 120.0;

  final opacity = 0.2;

  final fontSize = 14.0;

  final circularStrokeCap = CircularStrokeCap.round;

  final animation = false;

  List<Question?>? questionList = [];
  List<Answer?>? answerList = [];
  late AnimationController _controller;

//  List<Map<String, dynamic>> result = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQuestionList();
    setUpTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  setUpTimer() {
    _controller =
        AnimationController(vsync: this, duration: widget.timerDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              showTimeUpDialog(context, () {
                filterQuestionAndSyncToServer(context);
//                questionSyncToLocal(result,context);
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  getQuestionList() async {
    DatabaseManager dataBaseHelper = DatabaseManager();
    questionList = await dataBaseHelper.getQuestionList();
    answerList = await dataBaseHelper.getAnswerList();
    setState(() {});
  }

  Result filterQuestion(String? categoryId) {
    List<Question?>? filteredQuestionList = [];
    List<Question?>? answeredList = [];

    filteredQuestionList = questionList?.where((question) {
      if (question?.categoryId == categoryId) {
        question?.answerList = answerList?.where((answer) {
          return answer?.questionId == question.questionId;
        }).toList();
      }
      return question?.categoryId == categoryId;
    }).toList();

    answeredList = filteredQuestionList?.where((question) {
      var filteredAnswerList = question?.answerList
          ?.where((answer) => answer?.answered == 1)
          .toList();
      if ((filteredAnswerList?.length ?? 0) > 0) {
//        setUpQuestionData(question, filteredAnswerList.first);
        return true;
      }
      return false;
    }).toList();
    return Result(answeredList?.length ?? 0, filteredQuestionList?.length ?? 0);
  }

//
//  setUpQuestionData(Question question, Answer answer) {
//    Map<String, dynamic> filteredResult = {
//      "category_id": question.categoryId,
//      "question_id": question.questionId,
//      "is_correct": answer.isCorrect,
//      "answer": [answer.id]
//    };
//    if (question.subCategoryId.isNotEmpty){
//      filteredResult["sub_category_id"] = question.subCategoryId;
//    }
//    result.add(filteredResult);
//  }
//

  Color getColor(int percent, bool forBackground) {
    Color color;
    print(percent);
    if (percent >= 0 && percent <= 40) {
      color = Color.fromRGBO(255, 121, 175, forBackground ? opacity : 1);
    } else if (percent >= 41 && percent <= 60) {
      color = Color.fromRGBO(249, 183, 110, forBackground ? opacity : 1);
    } else if (percent >= 61 && percent <= 100) {
      color = Color.fromRGBO(82, 220, 128, forBackground ? opacity : 1);
    } else {
      color = Color.fromRGBO(82, 55, 20, forBackground ? opacity : 1);
    }
    return color;
  }

  getCenterWidget(Result result) {
    var percent = (result.answer / result.totalQuestion) * 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "${result.answer}",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: getColor(percent > 0.0 ? percent.toInt() : 0, false)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            "/${result.totalQuestion}",
          ),
        )
      ],
    );
  }

  getCircularProgress(int index) {
    var category = widget.categoryList?[index];
    var result = filterQuestion(category?.sId);
    print("result :${result.answer},${result.totalQuestion}");
    var percent = (result.answer / result.totalQuestion) * 100;

    return CircularPercentIndicator(
      radius: circleRadius,
      lineWidth: circleWidth,
      animation: animation,
      percent: percent / 100,
      center: getCenterWidget(result),
      footer: Text(
        "Total ${category?.name} answered",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
      circularStrokeCap: circularStrokeCap,
      progressColor: getColor(percent > 0.0 ? percent.toInt() : 0, false),
      backgroundColor: getColor(percent > 0.0 ? percent.toInt() : 0, true),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Overview",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Duration currentDuration =
                    (_controller.duration ?? Duration()) * _controller.value;
                widget.onFilterApplied(currentDuration);
                Navigator.pop(context);
              }),
          backgroundColor: appThemeColor,
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            GridView.builder(
              padding: EdgeInsets.only(bottom: 80),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // childAspectRatio: 10 / 8.5,
              ),
              itemBuilder: (BuildContext context, int position) {
                return getCircularProgress(position);
              },
              itemCount: widget.categoryList?.length,
            ),
            Container(
              padding: EdgeInsets.only(bottom: 16),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      showAlertWithTwoButton(
                          context,
                          "Are you sure you want to submit your test?",
                          Icon(
                            Icons.warning,
                            color: appThemeColor,
                            size: 40,
                          ), () {
                        filterQuestionAndSyncToServer(context);
//                        questionSyncToLocal(result,context);
                      }, () {
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      child: Text(
                        "Submit Test",
                        style: TextStyle(color: Colors.white),
                      ),
                      width: size.width / 2,
                      height: 40,
                      alignment: Alignment.center,
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(appThemeColor),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: Paddings.all2px,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          size: 20,
                        ),
                        Padding(
                          padding: Paddings.all8px,
                          child: OtpTimer(_controller, 15, Colors.black),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
