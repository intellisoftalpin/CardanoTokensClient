
import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class BackupRestoreEvent extends Equatable {
  const BackupRestoreEvent();

  @override
  List<Object> get props => [];
}

class BackupListFiles extends BackupRestoreEvent {
  final List<FileSystemEntity> listFiles;
  const BackupListFiles({required this.listFiles});

  @override
  List<Object> get props => [listFiles];
}


class BackupDb extends BackupRestoreEvent {
 // const BackupDb({required this.coin});
  const BackupDb();

  @override
  //List<Object> get props => [coin];
  List<Object> get props => [];
}

class DeleteZipFile extends BackupRestoreEvent {
  final String zipPath;

  const DeleteZipFile({required this.zipPath});

  @override
  List<Object> get props => [zipPath];
}
