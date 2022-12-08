import 'package:flutter/material.dart';
import 'package:flutter_geek_test/ui/splash_screen.dart';
import 'package:flutter_geek_test/utils/routing/at_root_screen.dart';
import 'package:flutter_geek_test/utils/routing/route_list.dart';

import 'utils/app_theme.dart';
import 'utils/constants/Colors.dart';
import 'utils/routing/routes.dart';

// Used globally in the app
late BuildContext globalContext;

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      // theme: ThemeData(
      //   fontFamily: 'PT_Sans',
      //   primarySwatch: Colors.blue,
      //   canvasColor: Colors.transparent,
      //   scaffoldBackgroundColor: Colors.white,
      //   primaryColor: appThemeColor,
      // ),
      onGenerateRoute: Routes.generateRoute,
      initialRoute: RouteList.splashScreen,
      home: AtRootScreen(
        screen: SplashScreen(),
      ),
    );
  }
}
