import 'package:flutter/material.dart';
import 'package:flutter_geek_test/app.dart';

class AtRootScreen extends StatelessWidget {
  final Widget screen;

  const AtRootScreen({
    Key? key,
    required this.screen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        globalContext = context;
        return screen;
      },
    );
  }
}
