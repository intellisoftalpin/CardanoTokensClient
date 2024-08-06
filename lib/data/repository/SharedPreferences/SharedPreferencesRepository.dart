import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ISharedPreferencesRepository.dart';

class SharedPreferencesRepository implements ISharedPreferencesRepository {

  static final SharedPreferencesRepository _singleton =
  new SharedPreferencesRepository._internal();

  factory SharedPreferencesRepository() {
    return _singleton;
  }

  SharedPreferencesRepository._internal();

  @override
  Future<bool> setLocalizedStrings(Map<String, String> localizedStrings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String localized = json.encode(localizedStrings);
    return prefs.setString(keyLocalizedStrings, localized);
  }

  @override
  Future<Map<String, dynamic>> getLocalizedStrings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(keyLocalizedStrings)!);
  }

  @override
  Future setTheme(int keyValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(keyTheme, keyValue);
  }

  @override
  Future getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(keyTheme) ?? 3;
  }

  @override
  Future setBackUp(String backUpKey, int backUpValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(backUpKey, backUpValue);
  }

  @override
  Future getBackUp(String backUpKey) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(backUpKey) ?? 0;
  }

  @override
  Future setExchange(double value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble(keyExchange, value);
  }

  @override
  Future getExchange() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble(keyExchange) ?? 0.0;
  }

  @override
  Future setExchangeTime(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(keyExchangeTime, value);
  }

  @override
  Future getExchangeTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(keyExchangeTime) ?? '';
  }
}

const keyLocalizedStrings = 'KEY_LOCALIZED_STRINGS';
const keyTheme = 'KEY_THEME';
const keyExchange = 'KEY_EXCHANGE';
const keyExchangeTime = 'KEY_EXCHANGE_TIME';
