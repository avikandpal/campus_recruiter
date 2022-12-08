import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geek_test/utils/manager/permissionManager.dart';
import 'package:permission_handler/permission_handler.dart';

///Singleton File For File Manager
class FilePickerManager {
  static final FilePickerManager _filePickerManager =
      FilePickerManager._internal();

  factory FilePickerManager() {
    return _filePickerManager;
  }

  FilePickerManager._internal();

  static Future<File?> pickCustomFile(
    BuildContext context,
  ) async {
    Object? object = await _pickLocalFiles(
      context: context,
      requireMultipleFile: false,
      fileType: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls'],
    );
    if (object != null) {
      if (object is File) {
        return object;
      }
    }
    return null;
  }

  static Future<List<File>?> pickCustomFiles(
    BuildContext context,
  ) async {
    Object? object = await _pickLocalFiles(
      context: context,
      fileType: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'xls'],
    );
    if (object != null) {
      if (object is List<File>) {
        return object;
      }
    }
    return null;
  }

  // Will Pick Custom files According to allowed extensions
  static Future<Object?> _pickLocalFiles({
    required BuildContext context,
    bool requireMultipleFile = true,
    required FileType fileType,
    List<String>? allowedExtensions,
  }) async {
    try {
      bool res = await PermissionManager.requestPermission(
          context: context, permission: Permission.storage);
      if (res) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: requireMultipleFile,
          allowedExtensions: allowedExtensions,
        );
        if (result != null) {
          if (requireMultipleFile) {
            List<File>? files;
            for (var element in result.files) {
              String? path = element.path;
              files?.add(File(path ?? ""));
            }
            return files;
          } else {
            String? filePath = result.files[0].path;
            File file = File(filePath ?? "");
            return file;
          }
        }
      }
    } catch (e) {
      debugPrint("Got Error While Trying To Fetch Local Files");
    }
    return null;
  }
}
