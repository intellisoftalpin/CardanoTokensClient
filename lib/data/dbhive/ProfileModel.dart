
import 'package:hive/hive.dart';
part 'ProfileModel.g.dart';

@HiveType(typeId: 1)
class ProfileModel  extends  HiveObject {

  @HiveField(0)
  String nameProfile;
  @HiveField(1)
  String id;

  ProfileModel({required this.nameProfile, required this.id});

  @override
  String toString() {
    return '${this.nameProfile}, ${this.id}';
  }

  @override
  bool operator == (Object other) =>
          other is ProfileModel && nameProfile == other.nameProfile &&
              id == other.id;

  @override
  int get hashCode => nameProfile.hashCode ^ id.hashCode;

}