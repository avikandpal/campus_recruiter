import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geek_test/ui/Home/home.dart';
import 'package:flutter_geek_test/ui/Home/instructions.dart';
import 'package:flutter_geek_test/ui/Login.dart';
import 'package:flutter_geek_test/ui/Tutorials.dart';
import 'package:flutter_geek_test/ui/overview.dart';
import 'package:flutter_geek_test/ui/select_category.dart';
import 'package:flutter_geek_test/ui/splash_screen.dart';
import 'package:flutter_geek_test/ui/upload_resume.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';
import '../../ui/question_list.dart';

class Routes {
  // Generates an error handling route screen
  static final Widget _errorRouteScreen = Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
    ),
    body: const Center(
      child: Text('Page not found'),
    ),
  );

  // Generates route and unwraps arguments
  static Route<dynamic> generateRoute(RouteSettings setting) {
    Widget? screen;
    switch (setting.name) {
      case RouteList.splashScreen:
        screen = SplashScreen();
        break;
      case RouteList.home:
        screen = Home();
        break;
      case RouteList.tutorials:
        screen = Tutorials();
        break;
      case RouteList.login:
        screen = Login();
        break;
      case RouteList.uploadResume:
        UploadResumeScreenArguments? arguments =
            _getScreenArguments<UploadResumeScreenArguments>(
                settingArgs: setting.arguments);
        screen = UploadResume(arguments?.user, arguments?.isLoggedIn ?? false);
        break;
      case RouteList.selectCategory:
        SelectCategoryScreenArguments? arguments =
            _getScreenArguments<SelectCategoryScreenArguments>(
                settingArgs: setting.arguments);
        screen = SelectCategory(arguments?.duration);
        break;
      case RouteList.instruction:
        InstructionsScreenArguments? arguments =
            _getScreenArguments<InstructionsScreenArguments>(
                settingArgs: setting.arguments);
        screen = InstructionsScreen(arguments?.instructionList ?? []);
        break;
      case RouteList.questionList:
        QuestionListScreenArguments? arguments =
            _getScreenArguments<QuestionListScreenArguments>(
                settingArgs: setting.arguments);
        screen = QuestionList(
          categoryList: arguments?.categoryList ?? [],
          subCategoryList: arguments?.subCategoryList ?? [],
          selectedCategoryId: arguments?.selectedCategoryId,
          categoryIndex: arguments?.categoryIndex ?? 0,
          subCategoryIndex: arguments?.subCategoryIndex ?? 0,
          duration: arguments?.duration ?? 1,
        );
        break;
      case RouteList.overView:
        OverViewScreenArguments? arguments =
            _getScreenArguments<OverViewScreenArguments>(
                settingArgs: setting.arguments);
        screen = Overview(
          categoryList: arguments?.categoryList,
          timerDuration: arguments?.timerDuration ?? Duration(),
          onFilterApplied: arguments?.onFilterApplied ?? (d) {},
        );
        break;
    }

    return buildRoute(
      settings: setting,
      screen: screen ?? _errorRouteScreen,
    );
  }

  // Reads and returns screen setting arguments
  static T? _getScreenArguments<T>({required Object? settingArgs}) {
    T? screenArguments;
    try {
      screenArguments = settingArgs as T;
    } catch (e) {
      screenArguments = null;
    }
    return screenArguments;
  }

  // Builds route with the respective screen
  static buildRoute<T>({
    RouteSettings? settings,
    T? returnType,
    required Widget screen,
  }) {
    return CupertinoPageRoute<T>(
      settings: settings,
      builder: (BuildContext context) => screen,
    );
  }
}
