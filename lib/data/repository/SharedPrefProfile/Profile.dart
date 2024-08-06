
class Profile {
  late String nameProfile;
  late String pass;

  Profile(String nameProfile, String pass);

  Profile.fromJson(Map<String, dynamic> json)
      : nameProfile = json['nameProfile'],
        pass = json['pass'];

  Map<String, dynamic> toJson() => {
    'nameProfile': nameProfile,
    'pass': pass,
  };
}
