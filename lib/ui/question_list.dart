import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/Category.dart';
import 'package:flutter_geek_test/model/question_model.dart';
import 'package:flutter_geek_test/ui/Menu.dart';
import 'package:flutter_geek_test/ui/otp.dart';
import 'package:flutter_geek_test/ui/overview.dart';
import 'package:flutter_geek_test/ui/question_text_widget.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:flutter_geek_test/utils/manager/database_manager.dart';
import 'package:flutter_geek_test/utils/persistence/constants.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';
import 'package:flutter_geek_test/utils/spacer/spacers.dart';
import 'package:flutter_geek_test/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/persistence/data/shared_prefs_keys.dart';

class QuestionListScreenArguments {
  final List<Category>? categoryList;
  final List<SubCategory>? subCategoryList;
  final String? selectedCategoryId;
  final int categoryIndex;
  final int subCategoryIndex;
  final int duration;

  QuestionListScreenArguments({
    required this.categoryList,
    required this.subCategoryList,
    required this.selectedCategoryId,
    required this.categoryIndex,
    required this.subCategoryIndex,
    required this.duration,
  });
}

class QuestionList extends StatefulWidget {
  List<Category>? categoryList;
  List<SubCategory>? subCategoryList = [];
  String? selectedCategoryId;
  int categoryIndex;
  int subCategoryIndex;
  int duration = 1;

  QuestionList({
    required this.categoryList,
    required this.subCategoryList,
    required this.selectedCategoryId,
    required this.categoryIndex,
    required this.duration,
    required this.subCategoryIndex,
  }) {
    print("Catgories ${categoryList?.length}");
    print("SubCatgories ${subCategoryList?.length}");
    print("categoryIndex $categoryIndex");
    print("subCategoryIndex $subCategoryIndex");
  }

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late Size screenSize;
  bool isShowFilter = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Question?>? questionList = [];
  List<Question?>? filteredQuestionList = [];
  PageController? _pageController;
  int? currentPageIndex = 0;
  ScrollController? _stepperScrollController;
  ScrollController? _subCategoryScrollController;
  AnimationController? _controller;
  String appTitle = "";

  // to check if filter is applied or not
  bool isFilterApplied = false;

  // to track app pauses
  var counter = 0;

  int selectedFilter = 0;

  // for page move timings
  var _duration = Duration(milliseconds: 300);

  // it will not let the build function execute again the future
  final AsyncMemoizer _memorizerData = AsyncMemoizer();
  final AsyncMemoizer _memorizerPage = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categoryIndex;
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: currentPageIndex ?? 0);
    _stepperScrollController = ScrollController();
    _subCategoryScrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController?.dispose();
    _stepperScrollController?.dispose();
    _subCategoryScrollController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    setUpTimer(Duration(seconds: widget.duration));
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (counter >= 3 && state == AppLifecycleState.paused) {
      _disqualifyDialog();
      return;
    }
    if (state == AppLifecycleState.paused) {
      counter += 1;
      var counterLeft = 3 - counter;
      var message = "";
      if (counterLeft == 0) {
        message =
            "You have left the app $counter times, once more, your test will be suspended.";
      } else {
        if (counter == 1) {
          message =
              "You have left the app $counter time, After $counterLeft times more, your test will be suspended.";
        } else {
          message =
              "You have left the app $counter times, After $counterLeft time more, your test will be suspended.";
        }
      }

      var title = Text("Alert!");
      var content = Text(message);
      var actions = <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"))
      ];

      /// user is allowed to leave app only three
      /// times so show  a message every time he leaves
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return defaultTargetPlatform == TargetPlatform.android
                ? AlertDialog(title: title, content: content, actions: actions)
                : CupertinoAlertDialog(
                    title: title, content: content, actions: actions);
          });
    }
  }

  void _disqualifyDialog() {
    var title = const Text("Alert!");
    var content = Text(
        "You have crossed the limit to open/close the App, So you are suspended from the test.");
    var actions = <Widget>[
      // usually buttons at the bottom of the dialog
      TextButton(
        child: Text("OK"),
        onPressed: () {
          disqualifyUser(context);
        },
      ),
    ];

    // show dialog with message and disqualify the user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return defaultTargetPlatform == TargetPlatform.android
            ? AlertDialog(
                title: title,
                content: content,
                actions: actions,
              )
            : CupertinoAlertDialog(
                title: title, content: content, actions: actions);
      },
    );
  }

  setUpTimer(Duration duration) {
    _controller = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          SharedPreferences.getInstance().then((pref) {
            pref.setBool(SharedPrefsKeys.isTimeOut, false);
            print('isTimeOut set');
          });
          showTimeUpDialog(context, () async {
            filterQuestionAndSyncToServer(context);
          });
        }
      });
    print("Controller Value ::::: ${_controller?.value}");
    _controller?.reverse(
        from: _controller?.value == 0.0 ? 1.0 : _controller?.value);
  }

  // Get question and answers from the database
  Future<List<Question>> setQuestionList() async {
    // setState will not call this again due to _memoizer
    return await _memorizerData.runOnce(() async {
      DatabaseManager dataBaseHelper = DatabaseManager();
      questionList = await dataBaseHelper.getQuestionList();
      List<Answer?>? answerList = await dataBaseHelper.getAnswerList();
      await genQuestionList(questionList, answerList);
    });
  }

  // Put answers in to the question's object
  Future<List<Question?>?> genQuestionList(
      List<Question?>? questions, List<Answer?>? answers) async {
    if (questions != null) {
      for (var question in questions) {
        if (answers != null) {
          for (var answer in answers) {
            // find out which answer is related to the question
            if (answer?.questionId == question?.questionId) {
              question?.answerList?.add(answer);
            }
          }
        }
      }
    }

    if (questionList != null) {
      /// find ouy the index of selected category at previous page
      /// So that we can move to that particular page accordingly
      for (var question in questionList!) {
        appTitle = widget.categoryList?[widget.categoryIndex].name ?? "-";
        if ((widget.subCategoryList?.length ?? 0) > 0) {
          var matched = question?.subCategoryId ==
              widget.subCategoryList?[widget.subCategoryIndex].sId;
          if (matched) {
            question?.isSelected = true;
            widget.subCategoryList?[widget.subCategoryIndex].isSelected = true;
            var index = questionList?.indexOf(question);
            currentPageIndex = index;
            break;
          }
        } else {
          var matched = question?.categoryId ==
              widget.categoryList?[widget.categoryIndex].sId;
          if (matched) {
            question?.isSelected = true;
            widget.categoryList?[widget.categoryIndex].isSelected = true;
            var index = questionList?.indexOf(question);
            currentPageIndex = index;
            break;
          }
        }
      }
      questionList?.forEach((element) {
        filteredQuestionList?.add(element);
      });
      print("CURRENT INDEX SELECTED $currentPageIndex");
      return questions;
    }
  }

  PreferredSizeWidget? getAppBar() {
    return AppBar(
      backgroundColor: appThemeColor,
      title: FutureBuilder(
          future: getDelay(),
          builder: (context, snapshot) {
            return Text(
              appTitle,
              style: TextStyle(color: Colors.white),
            );
          }),
      centerTitle: true,
      leading: getTimer(),
      actions: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              isShowFilter = !isShowFilter;
            });
          },
          child: Padding(
            padding: Paddings.all15px,
            child: Stack(
              children: <Widget>[
                Image.asset(
                  "images/filter.png",
                  height: 20.0,
                  width: 20.0,
                ),
                Container(
                  height: 8,
                  width: 8,
                  decoration: ShapeDecoration(
                      color:
                          isFilterApplied ? Colors.amber : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  /// find indexed question category and set its
  /// subcategories accordingly
  setUpQuestionView(int index) {
    var question = filteredQuestionList?[index];
    var filteredCategoryList = widget.categoryList?.where((category) {
      return category.sId == question?.categoryId;
    }).toList();
    //todo if is empty change app title

    if ((filteredCategoryList?.isNotEmpty ?? false) &&
        (question?.isSelected ?? false)) {
      var category = filteredCategoryList?.first;
      appTitle = category?.name ?? "-";
      setUpSubCategories(category, question);
    }
  }

  setUpSubCategories(Category? category, Question? question) {
    if (category?.subCategory?.isNotEmpty ?? false) {
      var filteredSubCategory = category?.subCategory?.where((subCatgeory) {
        subCatgeory.isSelected = false;
        return subCatgeory.sId == question?.subCategoryId;
      }).toList();
      if ((filteredSubCategory?.isNotEmpty ?? false) &&
          (question?.isSelected ?? false)) {
        filteredSubCategory?.first.isSelected = true;
      }
      widget.subCategoryList = category?.subCategory;
    } else {
      widget.subCategoryList = [];
    }
  }

  /// Basically it will generate a delay so the
  /// view can render itself and done with the
  /// calculations of data
  Future<Object> getDelay() async {
    return await _memorizerPage.runOnce(() {
      Timer(const Duration(milliseconds: 1000), () {
        move(currentPageIndex ?? 0);
      });
      return Future.delayed(const Duration(milliseconds: 500));
    });
  }

  Widget getCustomStepperWidget() {
    return FutureBuilder<Object>(
        future: getDelay(),
        builder: (context, snapshot) {
          return Container(
            height: 50,
            child: (filteredQuestionList?.length ?? 0) > 0
                ? ListView.builder(
                    padding: EdgeInsets.only(right: 10.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredQuestionList?.length,
                    controller: _stepperScrollController,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Question? question = filteredQuestionList?[index];
                      double stepperHeight =
                          (question?.isSelected ?? false) ? 28.0 : 22.0;
                      return Center(
                        child: Row(
                          children: <Widget>[
                            (index != 0)
                                ? Container(
                                    width: 10.0,
                                    height: 1.0,
                                    color: appThemeColor,
                                  )
                                : Spacers.width10px,
                            InkWell(
                              onTap: () {
                                move(index);
                              },
                              child: Container(
                                  width: stepperHeight,
                                  height: stepperHeight,
                                  decoration: BoxDecoration(
                                      color: (question?.isSelected ?? false)
                                          ? (question?.isAnswered ?? false)
                                              ? answerColor
                                              : appThemeColor
                                          : (question?.isAnswered ?? false)
                                              ? answerColor
                                              : lightBlue,
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w700),
                                  ))),
                            ),
                          ],
                        ),
                      );
                    })
                : Container(),
          );
        });
  }

  // move the  page after action(Filter, Select manually from the top count bar)
  move(int index) {
    if ((filteredQuestionList?.length ?? 0) > 0) {
      currentPageIndex = index;
      selectQuestion(index);
      moveToSpecificPage(index);
      setUpQuestionView(index);
    }
    setState(() {});
  }

  Widget getBottomButtons() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Container(
            height: 80.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                getBackButton(),
                getSubmitTestButton(),
                getNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// When user clicks on the NEXT or PREV button all the changes
  /// on the screen will be done by this function
  movePage(bool isNext) {
    // first changes the current index
    if (isNext) {
      currentPageIndex = (currentPageIndex ?? 0) + 1;
    } else {
      currentPageIndex = (currentPageIndex ?? 0) - 1;
    }
    scrollCounter();
    selectQuestion(currentPageIndex ?? 0);
    _pageController?.animateToPage(currentPageIndex ?? 0,
        duration: _duration, curve: Curves.ease);
    setUpQuestionView(currentPageIndex ?? 0);
    setState(() {});
  }

  // scroll the number counter that shows the current index of the question
  scrollCounter() {
    _stepperScrollController?.animateTo(getOffset(currentPageIndex ?? 0),
        duration: _duration, curve: Curves.ease);
  }

  Widget getBackButton() {
    return currentPageIndex == 0
        ? Container(height: 50, width: 70)
        : InkWell(
            onTap: () {
              movePage(false);
            },
            child: Container(
              height: 50.0,
              width: 70,
              alignment: Alignment.center,
              child: Text(
                '<< Prev',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
  }

  Widget getNextButton() {
    return filteredQuestionList?.length == (currentPageIndex ?? 0) + 1 ||
            filteredQuestionList?.length == 0
        ? Container(height: 50, width: 70)
        : InkWell(
            onTap: () {
              movePage(true);
            },
            child: Container(
              height: 50.0,
              width: 70,
              alignment: Alignment.center,
              child: Text(
                'Next >>',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
  }

  Widget getSubmitTestButton() {
    return Container(
      height: 35,
      width: 130,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(appThemeColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(35 / 2)),
            ),
          ),
        ),
        onPressed: () {
          Duration currentDuration =
              (_controller?.duration ?? Duration()) * (_controller?.value ?? 0);
          Navigator.pushNamed(context, RouteList.overView,
              arguments: OverViewScreenArguments(
                  categoryList: widget.categoryList,
                  timerDuration: currentDuration,
                  onFilterApplied: (_duration) {
                    setUpTimer(_duration);
                  }));
        },
        child: Text(
          'Submit Test',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget getTimer() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.access_time, color: Colors.white),
          Container(
              child: OtpTimer(_controller ?? AnimationController(vsync: this),
                  13, Colors.white)),
        ],
      ),
    );
  }

  selectQuestion(int index) {
    if ((filteredQuestionList?.length ?? 0) > 0) {
      filteredQuestionList?.forEach((question) => question?.isSelected = false);
      filteredQuestionList?[index]?.isSelected = true;
    }
  }

  moveToSpecificPage(int page) {
    print("page number ${page}");
    if ((filteredQuestionList?.isNotEmpty ?? false) &&
        (_pageController?.positions.isNotEmpty ?? false)) {
      _pageController?.animateToPage(page,
          duration: _duration, curve: Curves.easeIn);
    } else {
      Timer(Duration(milliseconds: 1000), () {
        move(currentPageIndex ?? 0);
      });
    }
  }

  Widget _getCustomTabBarList() {
    return Container(
        height: 39.0,
        child: ListView.builder(
            controller: _subCategoryScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.subCategoryList?.length,
            //physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return getCustomTabBar(index);
            }));
  }

  scrollTabs(int index) {
    _subCategoryScrollController?.animateTo(getOffset(index),
        duration: _duration, curve: Curves.ease);
  }

  // get offset to scroll the content
  getOffset(int index) {
    double offset;
    if (index <= 0) {
      offset = 1.0;
    } else {
      offset = index * 28.0;
    }
    return offset;
  }

  Widget getCustomTabBar(int index) {
    SubCategory? subCategory = widget.subCategoryList?[index];
    if (subCategory?.isSelected ?? false) {
      scrollTabs(index);
    }
    return InkWell(
      onTap: () {
        setState(() {
          if (filteredQuestionList?.isNotEmpty ?? false) {
            filteredQuestionList
                ?.forEach((question) => question?.isSelected = false);
            num loop = filteredQuestionList?.length ?? 0;
            for (var i = 0; i < loop; i++) {
              var value = filteredQuestionList?[i];
              if (subCategory?.sId == value?.subCategoryId) {
                value?.isSelected = true;
                currentPageIndex = i;
                widget.subCategoryList
                    ?.forEach((subCategory) => subCategory.isSelected = false);
                subCategory?.isSelected = true;
                moveToSpecificPage(i);
                break;
              }
            }
          }
        });
        scrollCounter();
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: Paddings.all8px,
            child: Text(
              subCategory?.name ?? "-",
              style: (subCategory?.isSelected ?? false)
                  ? TextStyle(
                      color: appThemeColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold)
                  : TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
            ),
          ),
          (subCategory?.isSelected ?? false)
              ? Container(
                  color: appThemeColor,
                  height: 2,
                  width: ((subCategory?.name?.length ?? 0) * 8).toDouble(),
                )
              : Container(
                  height: 0,
                  width: 0,
                )
        ],
      ),
    );
  }

  Widget _getQuestionList() {
    return FutureBuilder<List<Question>>(
        future: setQuestionList(),
        builder: (context, snapshot) {
          return Expanded(
            child: (filteredQuestionList?.length ?? 0) > 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: PageView.builder(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredQuestionList?.length,
                        itemBuilder: (BuildContext context, int index) {
                          var questionTemp = filteredQuestionList?[index];
                          var questionOriginal = questionList?[index];
                          return QuestionWidget(
                            questionTemp: questionTemp,
                            questionOriginal: questionOriginal,
                            index: index,
                            totalCount: filteredQuestionList?.length ?? 0,
                          );
                        }),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error,
                          size: 50.0,
                        ),
                        selectedFilter > 0
                            ? Text(
                                "No ${filterList[selectedFilter].title.toLowerCase()} questions for selected category.")
                            : Text("No questions found"),
                      ],
                    ),
                  ),
          );
        });
  }

  // Filter the list based on selected filter from the original question list
  filterSection(int filter) async {
    // before adding question to the exiting data source, clear it.
    filteredQuestionList?.clear();
    // After apply a filter view must be started from the first index
    currentPageIndex = 0;
    switch (filter) {
      case FilterSections.All:
        isFilterApplied = false;
        questionList?.forEach((element) {
          filteredQuestionList?.add(element);
        });
        break;
      case FilterSections.Attempted:
        isFilterApplied = true;
        filteredQuestionList = questionList?.where((question) {
          return question?.isAnswered ?? false;
        }).toList();
        break;
      case FilterSections.Unattempted:
        isFilterApplied = true;
        filteredQuestionList = questionList?.where((question) {
          return question?.isAnswered ?? false;
        }).toList();
        break;
      case FilterSections.Star:
        isFilterApplied = true;
        filteredQuestionList =
            questionList?.where((question) => question?.isFav == 1).toList();
        break;
    }
  }

  filterCategories(int categoryIndex) {
    if (categoryIndex != FilterSections.CategoryAll) {
      isFilterApplied = true;
      var category = widget.categoryList?[categoryIndex];
      filteredQuestionList?.removeWhere((question) {
        if (question?.categoryId != category?.sId) {
          return true;
        } else {
          return false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = Utils.getScreenSize(context);
    return WillPopScope(
      onWillPop: () async {
        return onWillPop(context);
      },
      child: Scaffold(
        appBar: getAppBar(),
        body: Stack(
          children: <Widget>[
            Scaffold(
              key: scaffoldKey,
              backgroundColor: backgroundColor,
              body: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, top: 5.0, right: 30),
                    child: (widget.subCategoryList?.length ?? 0) > 0
                        ? _getCustomTabBarList()
                        : Container(
                            height: 1.0,
                            color: Colors.white,
                          ),
                  ),
                  (widget.subCategoryList?.length ?? 0) > 0
                      ? Container(
                          height: 1.0,
                          color: Colors.grey,
                        )
                      : Container(),
                  getCustomStepperWidget(),
                  _getQuestionList(),
                  getBottomButtons()
                ],
              ),
            ),
            Offstage(
              offstage: !isShowFilter,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isShowFilter = false;
                  });
                },
                child: Container(
                  height: screenSize.height,
                  width: screenSize.width,
                  color: Colors.transparent.withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedContainer(
                color: Colors.transparent,
                duration: _duration,
                height: isShowFilter ? screenSize.height * 0.75 : 0.0,
                child: Filter(
                  widget.categoryList,
                  isShow: isShowFilter,
                  selectedFilter: selectedFilter,
                  onFilterApplied: (value, selectedFilter, selectedCategory) {
                    //todo change app bar title for empty list
                    if (selectedCategory != -1) {
                      var category = widget.categoryList?[selectedCategory];
                      appTitle = category?.name ?? "-";
                      widget.subCategoryList = [];
                    }
                    this.selectedFilter = selectedFilter;
                    isShowFilter = value;
                    filterSection(selectedFilter);
                    filterCategories(selectedCategory);
                    move(0);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
