class URLs {
  URLs._();

  static const String baseUrl = "https://www.backfour.co.uk/";
  static const String apiBaseUrl = baseUrl + "wp-json/v2/custom/";

  // Authentication
  static const String loginUrl = apiBaseUrl + "loginUser";
  static const String forgetPasswordUrl = apiBaseUrl + "forgetPassword";
  static const String requestAccessUrl = apiBaseUrl + "requestAccess";
  static const String getUserProfileUrl = apiBaseUrl + "getUserProfile";
  static const String updateUserProfileUrl = apiBaseUrl + "updateProfile";

  // Portal
  static const String getReportsUrl = apiBaseUrl + "reports";
  static const String getOtherReportsUrl = apiBaseUrl + "otherReports";
  static const String getGuidesUrl = apiBaseUrl + "guides";

  // Contact
  static const String contactUrl = apiBaseUrl + "contact_form";

  // Report a fake
  static const String reportPhysicalItemUrl = apiBaseUrl + "physicalFakeReports";
  static const String reportOnlineItemUrl = apiBaseUrl + "onlineFakeReports";
}
