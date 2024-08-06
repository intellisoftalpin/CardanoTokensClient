
abstract class SharedPrefProfileRepository {

  Future<String> readProfile(String key);
  Future<Set<String>> getAllProfile();
  saveProfile(String key, String value);
  delProfile(String key);
  Future<bool> containsKeyProfile(String key);
  saveCoinId(String key, String value);
  Future<String> readCoinId(String key);
  delCoinId(String key);

  Future setProfilesModels(Map<String, int> profilesModels);
  Future<Map<String, dynamic>> getProfilesModels();
}