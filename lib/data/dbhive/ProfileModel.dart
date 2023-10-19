import 'dart:convert';

class ProfileModel {
  String? nameProfile;
  String? id;
  int? pref;
  int? createDate;
  int? enterDate;

  ProfileModel(
      {this.nameProfile, this.id, this.pref, this.createDate, this.enterDate});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    nameProfile = json['nameProfile'];
    id = json['id'];
    pref = json['pref'];
    createDate = json['createDate'];
    enterDate = json['enterDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nameProfile'] = nameProfile;
    data['id'] = id;
    data['pref'] = pref;
    data['createDate'] = createDate;
    data['enterDate'] = enterDate;
    return data;
  }

  static Map<String, dynamic> toMap(ProfileModel profile) => {
        'nameProfile': profile.nameProfile,
        'id': profile.id,
        'pref': profile.pref,
        'createDate': profile.createDate,
        'enterDate': profile.enterDate,
      };

  static String encode(List<ProfileModel> habits) => json.encode(
        habits
            .map<Map<String, dynamic>>((profile) => ProfileModel.toMap(profile))
            .toList(),
      );

  static List<ProfileModel> decode(String habits) =>
      (json.decode(habits) as List<dynamic>)
          .map<ProfileModel>((item) => ProfileModel.fromJson(item))
          .toList();
}
