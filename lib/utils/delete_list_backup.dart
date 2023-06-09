import 'dart:io';

import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
as global;

import 'backup_restore.dart';

Future <void> deleteBackupList() async {
  List<FileSystemEntity> listFiles = [];
  String idProfile = global.idProfile;
  idProfile = idProfile.replaceAll("/", "*");
  print("idProfile = $idProfile");
  final zipFiles = "/zipFile/$idProfile";
  listFiles = await BackupRestore.getFilesFromDir(zipFiles);
  if (listFiles.isNotEmpty) {
    listFiles.sort(
            (a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));
  }
  print('FILES ALL::::::: $listFiles');
  try {
    if (listFiles.length > 1) {
      for (var i = 0; i < listFiles.length - 1; i++) {
        final dir = Directory(listFiles[i].path);
        idProfile = idProfile.replaceAll("/", "*");
        dir.deleteSync(recursive: true);
      }
      print("list.compareTo = $listFiles");
    }
  } on Exception catch (e) {
    print("Exception_backup: $e");
    throw CacheExeption();
  }
}

Future <void> deleteBackupListAll() async {
  List<FileSystemEntity> listFiles = [];
  String idProfile = global.idProfile;
  idProfile = idProfile.replaceAll("/", "*");
  print("idProfile = $idProfile");
  final zipFiles = "/zipFile/$idProfile";
  listFiles = await BackupRestore.getFilesFromDir(zipFiles);
  if (listFiles.isNotEmpty) {
    listFiles.sort(
            (a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));
  }
  print('FILES ALL::::::: $listFiles');
  try {
    if (listFiles.length >= 1) {
      for (var i = 0; i < listFiles.length; i++) {
        final dir = Directory(listFiles[i].path);
        idProfile = idProfile.replaceAll("/", "*");
        dir.deleteSync(recursive: true);
      }
      print("list after delete = $listFiles");
    }
  } on Exception catch (e) {
    print("Exception_backup: $e");
    throw CacheExeption();
  }
}
