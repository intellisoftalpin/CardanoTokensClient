
import 'dart:convert';

import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefProfileRepositoryImpl implements SharedPrefProfileRepository {

  @override
 Future<String> readProfile(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.getString(key).toString();
    return name;
  }

  @override
  saveProfile(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    prefs.reload();
  }

  @override
  Future<bool> containsKeyProfile(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getAllProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  @override
  delProfile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    prefs.reload();
  }

  @override
  saveCoinId(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    prefs.reload();
  }

  @override
  Future<String> readCoinId(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var coinId = prefs.getString(key).toString();
    return coinId;
  }

  @override
  delCoinId(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    prefs.reload();
  }

  @override
  Future setProfilesModels(Map<String, int> profilesModels) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String profiles = json.encode(profilesModels);
    return prefs.setString(keyProfilesModels, profiles);
  }

  @override
  Future<Map<String, dynamic>> getProfilesModels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(keyProfilesModels)!);
  }
}

const keyProfilesModels = 'KEY_PROFILES_MODELS';