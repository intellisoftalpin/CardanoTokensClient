
import 'dart:io';

import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
as global;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/backup_restore.dart';
import 'BackupRestoreEvent.dart';
import 'BackupRestoreState.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final DbRepository _dbRepository;
  String zipPath;

  BackupRestoreBloc(this._dbRepository, this.zipPath)
      : super(BackupRestoreState(BackupRestoreStatus.start)) {
    add(BackupListFiles(listFiles: []));
    add(DeleteZipFile(zipPath: ''));
  }

  @override
  Stream<BackupRestoreState> mapEventToState(BackupRestoreEvent event) async* {
    if (event is BackupListFiles) {
      yield* _getListBackup(event, state);
    }
    if (event is BackupDb) {
      // coinEntity = event.coin;
      yield* _setBackup(event);
    }
    if (event is DeleteZipFile) {
      zipPath = event.zipPath;
      yield* _deleteBackup(event);
    }
  }

  Stream<BackupRestoreState> _getListBackup(
      BackupRestoreEvent event, BackupRestoreState state) async* {
    List<FileSystemEntity> listFiles = [];
    String idProfile = global.idProfile;
    idProfile = idProfile.replaceAll("/", "*");
    print("idProfile = $idProfile");
    final zipFiles = "/zipFile/$idProfile";
    try {
      listFiles = await BackupRestore.getFilesFromDir(zipFiles);

      if (listFiles.isNotEmpty) {
        listFiles.sort((a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));
        print("list.compareTo = $listFiles");

        yield state.copyWith(BackupRestoreStatus.load, listFiles);
      } else {
        yield state.copyWith(BackupRestoreStatus.load, []);
      }
    } on Exception catch (e) {
      print("Exception_backup: $e");
      yield state.copyWith(BackupRestoreStatus.load, []);
      throw CacheExeption();
    }
  }

  Stream<BackupRestoreState> _setBackup(BackupRestoreEvent event) async* {
    List<FileSystemEntity> listFiles = [];
    String idProfile = global.idProfile;
    try {
      final dateTime = await getDate();
      await _dbRepository.openDb(global.idProfile, globals.pass);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = await _dbRepository.getPath();
      idProfile = idProfile.replaceAll("/", "*");
      final zipFileName = '[CT]' + idProfile + '.' + dateTime;
      final zipFiles = "/zipFile/$idProfile";
      var path = File(filePath).path;
      var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
      File newFile = await File(filePath).copy(path.substring(0, lastSeparator + 1) + 'r${idProfile}_ct.db');
      final String zippedFilePath = BackupRestore.zipFile(
        zipFileSavePath: directory.path + zipFiles,
        zipFileName: '/$zipFileName.zip',
        fileToZips: [newFile],
      );
      print(zippedFilePath);

      listFiles = await BackupRestore.getFilesFromDir(zipFiles);
      print("list = $listFiles");

      yield state.copyWith(BackupRestoreStatus.start);
    } on Exception catch (e) {
      print("Exception_backup: $e");
      throw CacheExeption();
    }
  }

  Stream<BackupRestoreState> _deleteBackup(BackupRestoreEvent event) async* {
    List<FileSystemEntity> listFiles = [];
    String idProfile = global.idProfile;
    try {
      final dir = Directory(zipPath);
      idProfile = idProfile.replaceAll("/", "*");
      final zipFiles = "/zipFile/$idProfile";

      dir.deleteSync(recursive: true);
      print("zipPath = $zipPath");

      listFiles = await BackupRestore.getFilesFromDir(zipFiles);
      print("list = $listFiles");

      yield state.copyWith(BackupRestoreStatus.start);
    } on Exception catch (e) {
      print("Exception_backup: $e");
      throw CacheExeption();
    }
  }

  Future<String> getDate() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    var timeformatter = new DateFormat('HH:mm:ss');
    String formattedTime = timeformatter.format(now);
    String formattedDate = formatter.format(now);
    print("formattedDate = $formattedDate, formattedTime= $formattedTime");
    String dateTime = formattedDate + '-' + formattedTime;

    return dateTime;
  }

  void createFileExternalStorage() async {
    try {
      final externalDirectory = await getExternalStorageDirectory();
      final dbFolder = await _dbRepository.getPath();
      print("dbFolder= $dbFolder, externalDirectory= $externalDirectory");

      File file1 = File('$externalDirectory');

      Directory copyTo = Directory("$dbFolder");
      if ((await copyTo.exists())) {
        // print("Path exist");
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      } else {
        print("not exist");
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          await copyTo.create();
        } else {
          print('Please give permission');
        }
      }

      String newPath = "${copyTo.path}/archiveDatabase.db";
      await file1.copy(newPath);
    } on Exception catch (e) {
      print("Exception_backup: $e");
      throw CacheExeption();
    }
  }
}