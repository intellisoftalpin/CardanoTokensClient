
import 'package:crypto/crypto.dart';
import 'dart:convert';

Digest hashPass(String pass) {
  var pass1 = utf8.encode(pass);
  var digest1 = sha256.convert(pass1);
  var pass2 = utf8.encode(digest1.toString());
  var digest2 = sha256.convert(pass2);
  var pass3 = utf8.encode(digest2.toString());
  var digest3 = sha256.convert(pass3);
  var pass4 = utf8.encode(digest3.toString());
  var digest4 = sha256.convert(pass4);
  var pass5 = utf8.encode(digest4.toString());
  var digest5 = sha256.convert(pass5);
  var pass6 = utf8.encode(digest5.toString());
  var digest6 = sha256.convert(pass6);
  var pass7 = utf8.encode(digest6.toString());
  var digest7 = sha256.convert(pass7);
  print("Digest as hex string: $digest1");
  print("Digest as hex string: $digest7");
  return digest7;
}