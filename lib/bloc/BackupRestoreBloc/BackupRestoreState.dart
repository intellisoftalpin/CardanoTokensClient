
import 'dart:io';

import 'package:equatable/equatable.dart';

class BackupRestoreState extends Equatable {
  // ignore: non_constant_identifier_names
  BackupRestoreState(this.state, [List<FileSystemEntity>? listFiles]) {
    this.listFiles = listFiles;
  }
  final BackupRestoreStatus state;
  late final List<FileSystemEntity>? listFiles;

  BackupRestoreState copyWith(BackupRestoreStatus status,  [List<FileSystemEntity>? listFiles]) {
    return BackupRestoreState(status, listFiles);
  }

  @override
  List<Object> get props => [state];
}

enum BackupRestoreStatus { start, load }
//backup, restore