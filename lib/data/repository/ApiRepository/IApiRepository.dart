import 'package:http/http.dart';

abstract class IApiRepository {

  Future<bool> check();
  Future<Response> getCardanoTokensList();
}