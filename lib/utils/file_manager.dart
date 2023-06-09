import 'dart:convert';
import 'dart:io';
import 'package:crypto_offline/data/dbhive/WalletModel.dart';
import 'package:crypto_offline/data/wallet.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';


class FileManager {
  static FileManager? _instance;

  FileManager._internal() {
    _instance = this;
  }

  factory FileManager() => _instance ?? FileManager._internal();

  static Future<String> get _directoryPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> fileJson(String id) async {
    final path = await _directoryPath;
    return File('$path/json/$id.json');
  }

  static Future<File> fileJsonCoin() async {
    final path = await _directoryPath;
    return File('$path/json/coins.json');
  }

  static Future<List<WalletModel>> readJson() async {
    List<WalletModel> listWallets = [];
    try {
      final String response = await rootBundle.loadString('assets/wallet.json');
      final List data = await json.decode(response);
      List<Wallet> listWallet = data.map((i) => Wallet.fromJson(i)).cast<
          Wallet>().toList();
      print("data = $data, listWallet 11 = $listWallet");
      listWallet.forEach((element) {
        var list = WalletModel(
            id: element.id!,
            name: element.name!,
            walletType: element.walletType,
            blockchains: element.blockchains,
            link: element.link,
            droid: element.droid,
            ios: element.ios,
            sort: element.sort);
        listWallets.add(list);
      });
      print("listWallet = $listWallet");
    } catch (e) {
      print(e);
    }
    return listWallets;
  }

  static GetStorage getStorage = GetStorage('MyStorage');

  static saveDateCache(String lastDate) {
    return  getStorage.write('lastDate', lastDate);
  }

  static readDateCache()  => getStorage.read('lastDate');

  static saveList(List listNeedToSave) async {
      /// save the new collection
      return await getStorage.write('listCoins', listNeedToSave);
  }
  /// read from the storage
  static readList()  => getStorage.read('listCoins');

  static saveCoinById(String key, var coinById) async {
   await getStorage.write('$key', json.encode(coinById));
   await getStorage.save();
  }

  static readCoinById(String key) async {
    var coinId  = await getStorage.read('$key');
    print("!!!!!coinId!!! $coinId" );
    if(coinId == null) {
      return null;
    } else
    return json.decode(coinId!);
  }

  static deleteCache() async => await getStorage.erase();

}