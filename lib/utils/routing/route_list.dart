class RouteList {
  ///Singleton Class
  static const RouteList _routeList = RouteList._internal();
  factory RouteList() {
    return _routeList;
  }
  const RouteList._internal();

  ///Routes
  static const String splashScreen = "/";
  static const String home = "/home";
  static const String tutorials = "/tutorials";
  static const String login = "/login";
  static const String uploadResume = "/uploadResume";
  static const String selectCategory = "/selectCategory";
  static const String instruction = "/instruction";
  static const String questionList = "/questionList";
  static const String overView = "/overView";

}
