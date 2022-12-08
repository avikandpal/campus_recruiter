import 'package:flutter/cupertino.dart';
import 'package:flutter_geek_test/utils/CommonFucntions.dart';
import 'package:permission_handler/permission_handler.dart';

///Singleton Class For Reusing Permission Checker
class PermissionManager {
  static final PermissionManager _permissionManager =
      PermissionManager._internal();

  factory PermissionManager() {
    return _permissionManager;
  }

  PermissionManager._internal();

  static Future<bool> requestPermission({
    required BuildContext context,
    required Permission permission,
  }) async {
    PermissionStatus _permissionStatus = await permission.request();
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        if (!isAndroid()) {
          _showSettingAlert(context, permission);
        }
        return false;
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.permanentlyDenied:
        _showSettingAlert(context, permission);
        return false;
      default:
        _showSettingAlert(context, permission);
        return false;
    }
  }

  static Future<bool> requestMultiplePermission({
    required BuildContext context,
    required List<Permission> permissions,
  }) async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    late bool allPermissionGranted = false;
    List<bool> permissionStatus = [];
    debugPrint("Multiple Status Result:::::: $statuses");
    statuses.forEach((key, value) {
      switch (value) {
        case PermissionStatus.denied:
          if (!isAndroid()) {
            _showSettingAlert(context, key);
          }
          // permissionStatus[key] = false;
          permissionStatus.add(false);
          return;
        case PermissionStatus.granted:
          // permissionStatus[key] = true;
          permissionStatus.add(true);
          break;
        case PermissionStatus.limited:
          // permissionStatus[key] = true;
          permissionStatus.add(true);
          break;
        case PermissionStatus.permanentlyDenied:
          if (isAndroid()) {
            _showSettingAlert(context, key);
          }
          // permissionStatus[key] = false;
          permissionStatus.add(false);
          return;
        default:
          _showSettingAlert(context, key);
          // permissionStatus[key] = false;
          permissionStatus.add(false);
          return;
      }
    });
    for (var element in permissionStatus) {
      if (element) {
        allPermissionGranted = true;
      } else {
        allPermissionGranted = false;
        break;
      }
    }
    return allPermissionGranted;
  }

  // static Future checkPermissionAndDoTask({
  //   required BuildContext context,
  //   required Permission permission,
  //   required String alertMessage,
  //   required Function() onPermissionSuccess,
  //   required Function() onPermissionFailure,
  // }) async {
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     final res = await _requestPermission(
  //       context: context,
  //       permission: permission,
  //       deniedMessage: alertMessage,
  //     );
  //     if (res == PermissionStatus.denied) {
  //       onPermissionFailure();
  //     } else {
  //       onPermissionSuccess();
  //     }
  //   } on PlatformException {
  //     debugPrint("Failed To Get Platform Version In Permission Manager");
  //   } catch (e) {
  //     debugPrint("Error While Trying To Access Permission Manager");
  //     rethrow;
  //   }
  // }

  static _showSettingAlert(BuildContext context, Permission permission) {
    showAlertWithChoiceButtons(
      context: context,
      titleText: "ERROR",
      message: _localizedMessageAccordingToPermission(context, permission),
      actionCallbacks: {
        "Not Now": () {},
        "Open Settings": () async {
          await Future.delayed(const Duration(
            milliseconds: 200,
          ));
          openAppSettings();
        },
      },
    );
  }

  static String _localizedMessageAccordingToPermission(
      BuildContext context, Permission rejectedPermission) {
    if (rejectedPermission == Permission.camera) {
      return "Camera Permission Not Granted";
    } else {
      return "Storage Permission Not Granted";
    }
  }
}
