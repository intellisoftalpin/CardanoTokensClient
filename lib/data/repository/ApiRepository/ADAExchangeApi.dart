import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../SharedPreferences/SharedPreferencesRepository.dart';
import 'ApiRepository.dart';

//final boxAda = GetStorage('adaExchange');
//
//class GetADAExchangeApi {
//
//  ApiRepository apiRepository = ApiRepository();
//
//  Future<List<dynamic>> getADAExchange() async {
//    final SharedPreferencesRepository _preferences = SharedPreferencesRepository();
//    String cardanoAnswerTime = '';
//    double cardanoAnswerCourse = 0.0;
//    double exchange = await _preferences.getExchange() ?? 0.0;
//    String exchangeTime = await _preferences.getExchangeTime() ?? '';
//    ApiRepository apiRepository = ApiRepository();
//    int now = DateTime.now().millisecondsSinceEpoch;
//    print('DateTime.now()::: $now');
//    int savedTime = boxAda.read('time') ?? 0;
//    if (savedTime == 0) {
//      print('TIME NOT SAVED');
//      await apiRepository
//          .getCardanoTokensList()
//          .then((value) async {
//        if (kDebugMode) {
//          print(value.statusCode);
//        }
//        if (value.statusCode == 200) {
//          var decodedR = json.decode(value.body);
//          if (kDebugMode) {
//            print("!!!SUCCESS!!!");
//            print('$decodedR');
//          }
//          cardanoAnswerTime = (decodedR["updated"] as String);
//          cardanoAnswerCourse = (decodedR["usd"] as double);
//          String time = cardanoAnswerTime.substring(0, cardanoAnswerTime.length - 1);
//          int gmt = DateTime.now().timeZoneOffset.inHours;
//          List<String> times = time.split('T');
//          DateTime dateFalse = DateTime.parse('${times.first} ${times.last}');
//          DateTime dateTrue = dateFalse.add(Duration(hours: gmt));
//          String timeToSave = DateFormat('dd.MM.yyyy, kk:mm:ss').format(dateTrue);
//          print('cardanoAnswerTime: $cardanoAnswerTime');
//          print('cardanoAnswerCourse: $cardanoAnswerCourse');
//          exchange = cardanoAnswerCourse;
//          _preferences.setExchange(exchange);
//          boxAda.write('time', now);
//          _preferences.setExchangeTime(timeToSave);
//          exchangeTime = timeToSave;
//        }
//      }).catchError((e) {
//        if (kDebugMode) {
//          print('===================error getADAExchange===================');
//          print(e);
//          print('===================error getADAExchange===================');
//        }
//      });
//    } else {
//      if (now - savedTime > 3600000) {
//        print('HOUR END');
//        boxAda.write('time', now);
//        await apiRepository
//            .getCardanoTokensList()
//            .then((value) async {
//          if (kDebugMode) {
//            print(value.statusCode);
//          }
//          if (value.statusCode == 200) {
//            var decodedR = json.decode(value.body);
//            if (kDebugMode) {
//              print("!!!SUCCESS!!!");
//              print('$decodedR');
//            }
//            cardanoAnswerTime = (decodedR["updated"] as String);
//            cardanoAnswerCourse = (decodedR["usd"] as double);
//            String time = cardanoAnswerTime.substring(0, cardanoAnswerTime.length - 1);
//            int gmt = DateTime.now().timeZoneOffset.inHours;
//            List<String> times = time.split('T');
//            DateTime dateFalse = DateTime.parse('${times.first} ${times.last}');
//            DateTime dateTrue = dateFalse.add(Duration(hours: gmt));
//            String timeToSave = DateFormat('dd.MM.yyyy, kk:mm:ss').format(dateTrue);
//            print('cardanoAnswerTime: $cardanoAnswerTime');
//            print('cardanoAnswerCourse: $cardanoAnswerCourse');
//            exchange = cardanoAnswerCourse;
//            _preferences.setExchange(exchange);
//            boxAda.write('time', now);
//            _preferences.setExchangeTime(timeToSave);
//            exchangeTime = timeToSave;
//          } else {
//            exchange = await _preferences.getExchange();
//            exchangeTime = await _preferences.getExchangeTime();
//          }
//        }).catchError((e) {
//          if (kDebugMode) {
//            print('===================error getADAExchange===================');
//            print(e);
//            print('===================error getADAExchange===================');
//          }
//        });
//      } else {
//        print('HOUR IN PROGRESS');
//        print('DIFF TIME:::${now - savedTime}');
//        exchange = await _preferences.getExchange();
//        exchangeTime = await _preferences.getExchangeTime();
//      }
//    }
//    return [exchange, exchangeTime];
//  }
//
//  Future<List<dynamic>> getForceADAExchange() async {
//    final SharedPreferencesRepository _preferences = SharedPreferencesRepository();
//    String cardanoAnswerTime = '';
//    double cardanoAnswerCourse = 0.0;
//    double exchange = await _preferences.getExchange() ?? 0.0;
//    String exchangeTime = await _preferences.getExchangeTime() ?? '';
//    ApiRepository apiRepository = ApiRepository();
//    int now = DateTime.now().millisecondsSinceEpoch;
//    print('DateTime.now()::: $now');
//    await apiRepository
//        .getCardanoTokensList()
//        .then((value) async {
//      if (kDebugMode) {
//        print(value.statusCode);
//      }
//      if (value.statusCode == 200) {
//        var decodedR = json.decode(value.body);
//        if (kDebugMode) {
//          print("!!!SUCCESS!!!");
//          print('$decodedR');
//        }
//        cardanoAnswerTime = (decodedR["updated"] as String);
//        cardanoAnswerCourse = (decodedR["usd"] as double);
//        String time = cardanoAnswerTime.substring(0, cardanoAnswerTime.length - 1);
//        int gmt = DateTime.now().timeZoneOffset.inHours;
//        List<String> times = time.split('T');
//        DateTime dateFalse = DateTime.parse('${times.first} ${times.last}');
//        DateTime dateTrue = dateFalse.add(Duration(hours: gmt));
//        String timeToSave = DateFormat('dd.MM.yyyy, kk:mm:ss').format(dateTrue);
//        print('cardanoAnswerTime: $cardanoAnswerTime');
//        print('cardanoAnswerCourse: $cardanoAnswerCourse');
//        exchange = cardanoAnswerCourse;
//        _preferences.setExchange(exchange);
//        _preferences.setExchangeTime(timeToSave);
//        exchangeTime = timeToSave;
//      }
//    }).catchError((e) {
//      if (kDebugMode) {
//        print('===================error getADAExchange===================');
//        print(e);
//        print('===================error getADAExchange===================');
//      }
//    });
//    return [exchange, exchangeTime];
//  }
//
//}