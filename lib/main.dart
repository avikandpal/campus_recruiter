import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geek_test/app.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: appThemeColor, //or set color with: Color(0xFF0000FF)
  ));
  runApp(App());
}
