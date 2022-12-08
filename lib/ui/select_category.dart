import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/Category.dart';
import 'package:flutter_geek_test/model/User.dart';
import 'package:flutter_geek_test/ui/otp.dart';
import 'package:flutter_geek_test/ui/question_list.dart';
import 'package:flutter_geek_test/network/ApiHandler.dart';
import 'package:flutter_geek_test/utils/constants/Appmessage.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/manager/database_manager.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/apis.dart';
import '../utils/persistence/data/shared_prefs_keys.dart';

class SelectCategoryScreenArguments {
  final int? duration;

  SelectCategoryScreenArguments(this.duration);
}

class SelectCategory extends StatefulWidget {
  int? duration;

  SelectCategory(this.duration);

  @override
  SelectCategoryState createState() {
    return SelectCategoryState();
  }
}

class SelectCategoryState extends State<SelectCategory>
    with TickerProviderStateMixin {
  Size? size;
  String studentName = "";
  List<Category> categoryList = [];
  var dataBAseHelper = DatabaseManager();
  AnimationController? _controller;
  var isExpanded = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
    setUpTimer(Duration(seconds: widget.duration ?? 0));
    _getCategoryListApi();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    User? user = await getUser;
    setState(() {
      studentName = user?.name ?? "-";
    });
  }

  setUpTimer(Duration duration) {
    print("Durtaion from SetUp$duration");
    _controller = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          showTimeUpDialog(context, () {
            filterQuestionAndSyncToServer(context);
          });
        }
      });
    _controller?.reverse(
        from: _controller?.value == 0.0 ? 1.0 : _controller?.value);
  }

  Widget getTimer() {
    return Container(
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.access_time),
          Spacers.width2px,
          OtpTimer(_controller!, 14, Colors.black),
        ],
      ),
    );
  }

  void _getQuizID() {
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.get(ApiNames.getQuestionId, context, (response) {
          if (response["status"] == 1) {
            String quizId = response["data"]["quiz_id"];
            print(quizId);
            setQuizID(quizId);
            _getQuestionList(quizId);
          } else {
            hideLoader(() {
              Navigator.pop(context);
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

  setQuizID(String quizId) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPrefsKeys.quizId, quizId);
  }

  validateQuizIdFromLocal() async {
    var prefs = await SharedPreferences.getInstance();
    var quizId = prefs.getString(SharedPrefsKeys.quizId);
    if (quizId == null || quizId.isEmpty) {
      print("quiz id empty");
      _getQuizID();
    } else {
      print("quix id :$quizId");
      _getQuestionList(quizId);
    }
  }

  _getQuestionList(String quizId) async {
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        var questionURL = "${ApiNames.question}$quizId";
        ApiHandler.get(questionURL, context, (response) {
          if (response["status"] == 1) {
            var data = response["data"];
            var questionList = data["questions"];
            var answerList = data["options"];
            print("data $data");
            print("questionList $questionList");
            print("answerList $answerList");
            saveDataLocaly(questionList, answerList);
          }
        });
      } else {
        showAlert(context, AppMessage.noInternetMessage, () {
          Navigator.pop(context);
        }, isWarning: true);
      }
    });
  }

  void _getCategoryListApi() {
    checkInternet((value) {
      if (value) {
        showLoader(context, "");
        ApiHandler.get(ApiNames.category, context, (response) {
          if (response["status"] == 1) {
            setState(() {
              print("Category Response : ${response["data"]}");
              setCategoryList(response["data"]);
              validateQuizIdFromLocal();
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

  saveDataLocaly(List questionList, List answerList) async {
    var dataBaseHelper = DatabaseManager();
    await dataBaseHelper.saveQuestionAndAnswerLocal(questionList, answerList);
  }

  void setCategoryList(List data) async {
    categoryList = [];
    data.forEach((v) {
      categoryList.add(Category.fromJson(v));
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return onWillPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Select Category",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: appThemeColor,
        ),
        body: Container(
          padding: EdgeInsets.only(top: 24),
          width: size?.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Please select a category to\ncontinue test",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                height: 1,
                color: lightGrayColor,
              ),
              Container(
                color: Color.fromRGBO(239, 239, 239, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: Paddings.all16px,
                      child: Text(
                        "Category",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: Paddings.all16px,
                      child: Text(
                        "Questions",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: lightGrayColor,
              ),
              getCategoryList(),
//              getOR(),
//              getContinueButton()
              getTimer()
            ],
          ),
        ),
      ),
    );
  }

  navigateToQuestionScreen(int categoryIndex, SubCategory? subCategory) {
    Category obj = categoryList[categoryIndex];
    var subCategoryIndex =
        subCategory == null ? -1 : obj.subCategory?.indexOf(subCategory);
    String? selectedID = "";
    if (subCategory != null) {
      selectedID = subCategory.sId;
      obj.subCategory?.forEach((subcategory) => subCategory.isSelected = false);
      subCategory.isSelected = true;
    } else {
      selectedID = obj.sId;
    }
    print("selectedID  $selectedID");
    categoryList.forEach((category) => category.isSelected = false);
    obj.isSelected = true;

    Duration currentDuration =
        (_controller?.duration ?? Duration()) * (_controller?.value ?? 0);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return QuestionList(
          categoryList: categoryList,
          subCategoryList: obj.subCategory,
          selectedCategoryId: selectedID,
          categoryIndex: categoryIndex,
          duration: currentDuration.inSeconds,
          subCategoryIndex: (subCategoryIndex ?? 0));
    }), (Route<dynamic> route) => false);
  }

  getCategoryList() {
    return Expanded(
      child: Container(
//        height: 500,
        height: size?.height,
        color: Colors.white,
        child: ListView.builder(
          itemBuilder: (context, position) {
            Category category = categoryList[position];
            return ExpansionTile(
              initiallyExpanded: isExpanded,
              title: Text(
                category.name ?? "-",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: appThemeColor),
              ),
              onExpansionChanged: (value) {
                isExpanded = value;
                print(value);
                var category = categoryList[position];
                category.isExpanded = value;
                if (category.subCategory == null ||
                    category.subCategory?.length == 0) {
                  navigateToQuestionScreen(position, null);
                } else {
                  setState(() {});
                }
              },
              trailing: Container(
                width: 63.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    CircleAvatar(
                      child: Text(
                        "${category.numberOfQuestion}",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      backgroundColor: appThemeColor,
                      radius: 14,
                    ),
                    (category.subCategory?.length ?? 0) > 0
                        ? Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black,
                          )
                        : SizedBox(
                            width: 24,
                            height: 24,
                          )
                  ],
                ),
              ),
              children: (category.subCategory?.length ?? 0) > 0
                  ? category.subCategory!.map((val) {
                      return InkWell(
                        onTap: () {
                          var index = category.subCategory?.indexOf(val);
                          navigateToQuestionScreen(position, val);
                        },
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24, right: 16, top: 16, bottom: 16),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(val.name ?? "-",
                                          style: TextStyle(fontSize: 18))),
                                  CircleAvatar(
                                    child: Text(
                                      "${val.numberOfQuestion}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    backgroundColor: appThemeColor,
                                    radius: 14,
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  : [],
            );
          },
          itemCount: categoryList.length,
        ),
      ),
    );
  }

  getOR() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              color: lightGrayColor,
              height: 1,
            ),
          ),
        ),
        Padding(
          padding: Paddings.all4px,
          child: Text(
            "OR",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              color: lightGrayColor,
              height: 1,
            ),
          ),
        )
      ],
    );
  }

  getContinueButton() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: TextButton(
        onPressed: () {
          //TODO SUBMIT TEST HERE
          var subCategoryList = categoryList.first.subCategory;
          if (subCategoryList?.isNotEmpty ?? false) {
            navigateToQuestionScreen(0, subCategoryList?.first);
          } else {
            navigateToQuestionScreen(0, null);
          }
        },
        child: Container(
          child: Text(
            "Continue in Sequence",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          width: (size?.width ?? 0) / 2,
          height: 50,
          alignment: Alignment.center,
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(appThemeColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),
    );
  }
}
