
import 'package:hive/hive.dart';
part 'CoinsModel.g.dart';

@HiveType(typeId: 2)
class CoinsModel extends HiveObject {

  @HiveField(0)
  String id;


  CoinsModel({required this.id});

  @override
  String toString() {
    return '${this.id}';
  }

}
