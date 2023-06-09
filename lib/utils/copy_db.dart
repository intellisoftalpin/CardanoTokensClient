import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


Future<void> copyDB(String name, String newName) async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String oldDBPath = join(documentsDirectory.path, (name + ".db"));
  String newDBPath = join(documentsDirectory.path, (newName + ".db"));
  print(oldDBPath);
  print(newDBPath);

  try {
    final file = File(oldDBPath);
    file.copy(newDBPath);
  } catch (e) {
    print(e);
  }
}