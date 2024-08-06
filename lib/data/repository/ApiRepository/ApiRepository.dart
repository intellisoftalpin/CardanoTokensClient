import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:http/http.dart';

class ApiRepository implements IApiRepository {

  @override
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  Future<Response> getCardanoTokensList() async {
    final response = await get(
      Uri.parse(coinsCardanoListUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }


  // https://ctokens.io/api/v1/tokens/
  // https://ctokens.io/api/v1/tokens/images/29d222ce763455e3d7a09a665ce554f00ac89d2e99a1a83d267170c6.4d494e.png
  static const String servCardanoUrl = "https://ctokens.io/api/v1";
  final String coinsCardanoListUrl = servCardanoUrl + "/tokens/";
}
