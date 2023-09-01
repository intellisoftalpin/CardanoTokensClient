
import 'package:crypto_offline/data/dbhive/CoinsModel.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/data/dbhive/WalletModel.dart';

abstract class HivePrefProfileRepository {
  Future<List<ProfileModel>> showProfile();
  renameProfile(String name, String newName, String idProfile, int pref);
  saveProfile(String nameProfile, String idProfile, int pref);
  //getProfile();
  //Future<String> getProfileByName(String name);
  Future<List<ProfileModel>> deleteGroupFrom(String name, String idProfile);

  Future<List<CoinsModel>> showCoins();
  saveCoinId(String id);
  deleteAllCoins();
  Future<String>  getSaveData();
  Future<List<CoinsModel>> getCoinId();
  Future<double> getCoinByIdPrice(String id);

  Future<List<WalletModel>> showWallet();
  Future<void> saveWallets(List<WalletModel> listWallets);
  Future<void> saveWallet(WalletModel wallet);
  Future<List<WalletModel>> getWalletByNane(String name);
}