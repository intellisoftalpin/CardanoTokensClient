import 'dart:io';

import 'package:crypto_offline/app.dart'
    as recovery;

bool recoverySizeSmall() {
  bool sizeSmall = true;
  String path = recovery.recoveryPath!;
  var file = File(path);
  int size = file.lengthSync();
  print('RECOVERY SIZE:::${file.lengthSync()}');
  if (size <= 10000000) {
    sizeSmall = true;
  } else {
    sizeSmall = false;
  }
  return sizeSmall;
}
