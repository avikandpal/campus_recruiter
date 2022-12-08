class ApiNames {
  /// OLD ONE
//var baseUrl = "http://192.168.0.153:3038";
  /// NEW OLD ONE
// var baseUrl = "http://campusapi.debutinfotech.com";
  static const String baseUrl = "http://api-hireme.debutinfotech.com";

  static const apiVersion = "/v1/";

  //MARK:-FunctionNames.
  static String companyName = "$baseUrl" + "company_name";
  static String login = "$baseUrl" + "$apiVersion" + "verify";
  static String resendOtp = "$baseUrl" + "$apiVersion" + "send_otp";
  static String verifyOtp = "$baseUrl" + "$apiVersion" + "verify_otp";
  static String instructions = "$baseUrl" + "$apiVersion" + "quiz/instruction";
  static String schedule = "$baseUrl" + "$apiVersion" + "quiz/schedule";
  static String category = "$baseUrl" + "$apiVersion" + "categories";
  static String profile = "$baseUrl" + "$apiVersion" + "profile";
  static String cv = "$baseUrl" + "$apiVersion" + "profile/cv";
  static String getQuestionId = "$baseUrl" + "$apiVersion" + "question";
  static String question = "$baseUrl" + "$apiVersion" + "test?quiz_id=";
  static String syncQuestion = "$baseUrl" + "$apiVersion" + "sync";
  static String submitTest = "$baseUrl" + "$apiVersion" + "test/submit";
  static String help = "$baseUrl" + "$apiVersion" + "help";
  static String invalidTest = "$baseUrl" + "$apiVersion" + "test/submitInvalid";
  static String uploadCv = "$baseUrl" + "$apiVersion" + "resume";

  static String syncData = "$baseUrl" + "sync";
  static String logout = "$baseUrl" + "logout";
}
