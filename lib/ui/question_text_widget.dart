import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/question_model.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/manager/database_manager.dart';
import 'package:flutter_geek_test/utils/reusable_widgets/ImagePreview.dart';

import '../utils/spacer/spacers.dart';

class QuestionWidget extends StatefulWidget {
  final Question? questionTemp;
  final Question? questionOriginal;
  final int index;
  final int totalCount;

  QuestionWidget({
    required this.questionTemp,
    required this.questionOriginal,
    required this.index,
    required this.totalCount,
  });

  @override
  QuestionWidgetState createState() {
    return QuestionWidgetState();
  }
}

class QuestionWidgetState extends State<QuestionWidget> {
  Widget getQuestionCardWidget() {
    Size screenSize = MediaQuery.of(context).size;
    var image =
        widget.questionTemp?.isFav == 1 ? Icons.star : Icons.star_border;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: <Widget>[
          Image.asset(
            "images/question-bg.png",
            fit: BoxFit.cover,
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
//                      SizedBox(height: 0.0,),
                      Text(
                        'Question ${widget.index + 1}/${widget.totalCount}',
                        style: TextStyle(color: grey),
                      ),
                      InkWell(
                        child: Icon(
                          image,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onTap: () {
                          widget.questionTemp?.isFav =
                              widget.questionTemp?.isFav == 0 ? 1 : 0;
                          widget.questionOriginal?.isFav =
                              widget.questionTemp?.isFav;
                          setState(() {});
                          favoriteQuestionDB(widget.questionTemp);
                        },
                      ),
                    ],
                  ),
                  Text(
                    widget.questionTemp?.question ?? "-",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Spacers.height15px,
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (ImagePreview(
                                  widget.questionTemp?.image ?? "-"))));
                    },
                    child: Container(
                      width: screenSize.width,
                      child: (widget.questionTemp?.image != null)
                          ? Image.network(
                              widget.questionTemp!.image!,
                              fit: BoxFit.cover,
                              height: 150.0,
                            )
                          : Container(),
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

  // Mark the question as favorite in the database asynchronously
  favoriteQuestionDB(Question? question) async {
    var databaseHelper = DatabaseManager();
    databaseHelper.markQuestionFav(question);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Container(
          child: Column(
            children: <Widget>[
              getQuestionCardWidget(),
              AnswerOptions(
                questionTemp: widget.questionTemp,
                questionOriginal: widget.questionOriginal,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AnswerOptions extends StatefulWidget {
  final Question? questionTemp;
  final Question? questionOriginal;

  AnswerOptions({this.questionTemp, this.questionOriginal});

  @override
  AnswerOptionsState createState() {
    return AnswerOptionsState();
  }
}

class AnswerOptionsState extends State<AnswerOptions> {
  Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.questionTemp?.answerList?.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(left: 4, right: 4, top: 6, bottom: 6),
          decoration:
              BoxDecoration(shape: BoxShape.rectangle, color: Colors.white),
          child: Material(
            elevation: 4,
            color: Colors.white,
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                print("Answer Index $index");
                var answerTemp = widget.questionTemp?.answerList?[index];
                var answerOriginal =
                    widget.questionOriginal?.answerList?[index];

                if (answerTemp?.answered == 1) {
                  print("Answer Unselect");
                  answerTemp?.answered = 0;
                  answerOriginal?.answered = 0;

                  widget.questionTemp?.isAnswered = false;
                  widget.questionOriginal?.isAnswered = false;

                  DatabaseManager().selectAnswer(answerOriginal, false);
                  DatabaseManager().answered(widget.questionOriginal, false);
                } else {
                  print("Answer select");
                  widget.questionTemp?.answerList
                      ?.forEach((answer) => answer?.answered = 0);
                  widget.questionOriginal?.answerList
                      ?.forEach((answer) => answer?.answered = 0);

                  answerTemp?.answered = 1;
                  answerOriginal?.answered = 1;

                  widget.questionTemp?.isAnswered = true;
                  widget.questionOriginal?.isAnswered = true;

                  DatabaseManager().selectAnswer(answerOriginal, true);
                  DatabaseManager().answered(widget.questionOriginal, true);
                }

                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: AnimatedDefaultTextStyle(
                      duration: _duration,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      child: Text(
                          "${widget.questionTemp?.answerList?[index]?.id}.  ${widget.questionTemp?.answerList?[index]?.option}"),
                    )),
                    (widget.questionTemp?.answerList?[index]?.answered == 1)
                        ? Image.asset(
                            'images/rightQuestion.png',
                            height: 32,
                            width: 32,
                          )
                        : Container(
                            height: 32,
                            width: 32,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
