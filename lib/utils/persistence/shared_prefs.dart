import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'data/shared_prefs_keys.dart';

class SharedPrefs {
  SharedPrefs._();

  static Future<SharedPreferences> get instance async {
    return await SharedPreferences.getInstance();
  }

  // Methods

  // Saves login status to Shared preferences
  static Future<bool> saveLoginStatus({
    required bool loggedIn,
  }) async {
    var _prefs = await instance;
    return await _prefs.setBool(SharedPrefsKeys.isLoggedIn, loggedIn);
  }

  // Gets login status from Shared preferences
  static Future<bool> getLoginStatus() async {
    var _prefs = await instance;
    return _prefs.getBool(SharedPrefsKeys.isLoggedIn) ?? false;
  }

  // Saves user to Shared preferences
  // static Future<bool> saveUser({
  //   required User user,
  // }) async {
  //   var _prefs = await instance;
  //   return await _prefs.setString(
  //     SharedPrefsKeys.user,
  //     jsonEncode(user.toJson()),
  //   );
  // }

  // // Gets user from Shared preferences
  // static Future<User?> getUser() async {
  //   var _prefs = await instance;
  //   if (_prefs.containsKey(SharedPrefsKeys.user)) {
  //     var userJson = _prefs.getString(SharedPrefsKeys.user);
  //     return User.fromJson(jsonDecode(userJson ?? ''));
  //   }
  //   return null;
  // }

  // Removes user from Shared preferences
  static Future<bool> removeUser() async {
    var _prefs = await instance;
    if (_prefs.containsKey(SharedPrefsKeys.user)) {
      var removed = _prefs.remove(SharedPrefsKeys.user);
      return removed;
    }
    return false;
  }
}
