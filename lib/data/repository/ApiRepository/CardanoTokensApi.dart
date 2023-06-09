import 'dart:convert';

import 'package:crypto_offline/data/model/CardanoModel.dart';
import 'package:flutter/foundation.dart';
import 'ApiRepository.dart';

class CardanoTokensApi {

  Future<List<Tokens>> getCardanoTokens() async {
    List<Tokens> cardanoList = [];
    ApiRepository apiRepository = ApiRepository();
    await apiRepository
        .getCardanoTokensList()
        .then((value) async {
      if (kDebugMode) {
        print(value.statusCode);
      }
      if (value.statusCode == 200) {
        Map data = jsonDecode(value.body);
        cardanoList = (data["tokens"] as List)
            .map((e) => Tokens.fromJson(e))
            .cast<Tokens>()
            .toList();
        print("CardanoTokens::: $cardanoList");
      }
    }).catchError((e) {
      if (kDebugMode) {
        print('===================error getCardanoTokens===================');
        print(e);
        print('===================error getCardanoTokens===================');
      }
    });
    return cardanoList;
  }
}