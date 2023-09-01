import 'dart:io';

import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/dbhive/HivePrefProfileRepository.dart';
import '../../data/repository/SharedPreferences/SharedPreferencesRepository.dart';
import '../../utils/backup_restore.dart';
import '../../utils/delete_db.dart';

part 'ChangePassProfileEvent.dart';

part 'ChangePassProfileState.dart';

class ChangePassProfileBloc
    extends Bloc<ChangePassProfileEvent, ChangePassProfileState> {
  DbRepository _dbRepository;
  final HivePrefProfileRepository _hiveProfileRepository;
  String profile;
  String nameProfile;
  String pass;
  String newProfilePath;
  String newNameProfile;
  String newProfilePass;
  int passPref;

  ChangePassProfileBloc(
      this._dbRepository,
      this._hiveProfileRepository,
      this.profile,
      this.nameProfile,
      this.pass,
      this.newProfilePath,
      this.newNameProfile,
      this.newProfilePass,
      this.passPref)
      : super(ChangePassProfileState(ChangePassProfileStatus.start)) {
    add(ChangePassProfile(
        profile: profile,
        nameProfile: nameProfile,
        pass: pass,
        newProfilePath: newProfilePath,
        newNameProfile: newNameProfile,
        newProfilePass: newProfilePass,
        passPref: passPref));
  }

  @override
  Stream<ChangePassProfileState> mapEventToState(
      ChangePassProfileEvent event) async* {
    if (event is ChangePassProfile) {
      yield* _migrationProfile(event);
    }
  }

  Stream<ChangePassProfileState> _migrationProfile(
      ChangePassProfileEvent event) async* {
    try {
      if (profile.isNotEmpty && pass.isNotEmpty ||
          profile != '' && pass != '' && profile != 'null') {
        print('OLD:::: $profile; NEW:::: $newProfilePath');
        print('OLD PASS:::: $pass; NEW PASS:::: $newProfilePass');
        print('OLD NAME:::: $nameProfile; NEW NAME:::: $newNameProfile');
        print('OLD idProfile:::: $profile; NEW idProfile:::: $newProfilePath');
        await _dbRepository.openDb(profile, pass);
        await _dbRepository.dbMigration(newProfilePath, newProfilePass);
        await _dbRepository.closeDb(newProfilePath, newProfilePass);
        //_hiveProfileRepository.getProfile();
        await deleteDB(profile);
        await _dbRepository.closeDb(newProfilePath, newProfilePass);
        var profiles1 = await _hiveProfileRepository.showProfile();
        print('profiles_before_del: $profiles1');
        var profiles =
            await _hiveProfileRepository.deleteGroupFrom(nameProfile, profile);
        print('profiles_after_del: $profiles');
        var profiles2 = await _hiveProfileRepository.showProfile();
        print('showProfile()_after_del: $profiles2');

        //final zipFiles = "/zipFile/$profile";
        final zipFiles = "/zipFile/$newProfilePath";
        List<FileSystemEntity> listFiles =
            await BackupRestore.getFilesFromDir(zipFiles);
        SharedPreferencesRepository _preferences =
            SharedPreferencesRepository();
        int backUp = await _preferences.getBackUp(profile);
        _preferences.setBackUp(newProfilePath, backUp);
        if (listFiles.isNotEmpty) {
          for (var file in listFiles) {
            final directory = await getApplicationDocumentsDirectory();
            String fileName = file.path;
            var list1 = fileName.split("/").last;
            var fileDate = list1.split(".").elementAt(1);

            var pathFile = directory.path + "/unzipFile";
            var unzipFile = await BackupRestore.unzipFile(
                zipFile: (file as File), extractToPath: pathFile);
            var newFileName = await BackupRestore.changeFileNameOnly(
                unzipFile, newProfilePath + '.db');
            print(
                " unzipFile = $unzipFile, fileDate = $fileDate, newFileName = $newFileName");
            final dir = Directory(fileName);
            dir.deleteSync(recursive: true); //deleting old file
            final zipFileName = newProfilePath + '.' + fileDate;
            final zipFiles = "/zipFile/$newProfilePath";
            final String zippedFilePath = BackupRestore.zipFile(
              zipFileSavePath: directory.path + zipFiles,
              zipFileName: '/$zipFileName.zip',
              fileToZips: [File(newFileName.path)],
            );
            final dirUnzip = Directory(pathFile);
            dirUnzip.deleteSync(
                recursive: true); //deleting temp file in unzip storage
            print("zippedFilePath = $zippedFilePath");
          }
        }
        yield state.copyWith(ChangePassProfileStatus.start);
      }
    } on Exception catch (e) {
      print(Error.safeToString(e));
      print("Exception $e");
    }
  }
}
