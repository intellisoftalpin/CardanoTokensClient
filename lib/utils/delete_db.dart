import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


Future<void> deleteDB(String name) async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, (name + ".db"));
  print('DB deleted:::$path');

  try {
    final file = File(path);
    await file.delete();
  } catch (e) {
    print(e);
  }
}
