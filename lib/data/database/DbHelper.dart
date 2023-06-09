
import 'package:sqflite_sqlcipher/sqflite.dart' show Database;

abstract class DbHelper {

  Future<Database?> openDb(String name, String pass);

  closeDb();
}