
import 'package:hive/hive.dart';
part 'WalletModel.g.dart';

@HiveType(typeId: 3)
class WalletModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? walletType;
  @HiveField(3)
  String? blockchains;
  @HiveField(4)
  String? link;
  @HiveField(5)
  String? droid;
  @HiveField(6)
  String? ios;
  @HiveField(7)
  String? sort;

  WalletModel({required this.id, required this.name, this.walletType, this.blockchains,
     this.link, this.droid, this.ios,  this.sort});

  @override
  String toString() {
    return '${this.id}, ${this.name}, ${this.walletType}, ${this.blockchains}, ${this.link},'
        '${this.droid}, ${this.ios}, ${this.sort}';
  }
}