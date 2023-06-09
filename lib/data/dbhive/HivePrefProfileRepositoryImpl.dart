
import 'package:crypto_offline/data/dbhive/CoinsModel.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:hive/hive.dart';

import 'HivePrefProfileRepository.dart';
import 'WalletModel.dart';

class HivePrefProfileRepositoryImpl extends HivePrefProfileRepository {
  @override
  Future<List<ProfileModel>> deleteGroupFrom(String name, String idProfile) async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProfileModelAdapter());
    }
    final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
    var profiles = box.values.toList();
    int index = profiles.indexWhere((element) =>
    element.nameProfile == name && element.id == idProfile);
    if(index < 0){
      index = 0;
    }
    box.deleteAt(index);
    profiles = box.values.toList();
    print('PROFILES deleteGroupFrom:::::::::: $profiles');
    return profiles;
  }

  @override
  renameProfile(String name, String newName, String idProfile) async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProfileModelAdapter());
    }
    final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
    var profiles = box.values.toList();
    print('PROFILES::::: $profiles');
    int index = profiles.indexWhere((element) =>
    element.nameProfile == name && element.id == idProfile);
    if(index < 0){
      index = 0;
    }
    print('PROFILES::::: $profiles; INDEX::::::: $index; NAME::::::::: $name; NEWNAME:::::::::::::: $newName');
    box.deleteAt(index);
    box.add(ProfileModel(nameProfile: newName, id: idProfile));
    //box.add(ProfileModel(nameProfile: newName));
    //profiles[index].nameProfile = newName;
    //box.putAt(index, ProfileModel(nameProfile: newName));
    //profiles.insert(index, ProfileModel(nameProfile: newName));
  }

  @override
   saveProfile(String nameProfile, String idProfile) async {
    try {
      if (nameProfile.isEmpty) return;
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }
      final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
      final profile = ProfileModel(nameProfile: nameProfile, id: idProfile);
      box.add(profile);
    } on Exception catch (e) {
    print(Error.safeToString(e));
    }
  }

  @override
  getProfile() async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }
      final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
      var profiles = box.values.toList();
      print('PROFILES AFTER CHANGE PASSWORD:::::::::: $profiles');
      return profiles;
    } on Exception catch (e) {
      print(Error.safeToString(e));
    }
  }

  @override
    Future<String> getProfileByName(String name) async {
    String profileId = '';
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }
      final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
      if(box.isNotEmpty) {
        var profile = box.values.toList();
        for( var e in profile) {
          if(e.nameProfile == name) {
            profileId = e.id;
          }
        }
        print('PROFILES  profileId::::::::: $profileId');
      }
    } on Exception catch (e) {
      print(Error.safeToString(e));
    }
    return profileId;
  }

  @override
  Future<List<ProfileModel>> showProfile() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProfileModelAdapter());
    }
    final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
    var profiles = box.values.toSet().toList();
    print(profiles);
    return profiles;
  }

  @override
  deleteAllCoins() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    box.clear();
  }

  @override
  saveCoinId(String id) async {
    if (id.isEmpty) return;
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    final coinId = CoinsModel(id: id);
    box.add(coinId);
    print(coinId);
  }

  Future<String> getSaveData() async {
    String date = '';
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    if(box.isNotEmpty) {
      //saveDats = box.values.first;
      //date = box.getAt(0)!.date!;
      print("saveDats =  date = $date");
    }
      return date;
  }

  Future<List<CoinsModel>> getCoinId() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    var coinsId = box.values.toList();
    print(coinsId);
    return coinsId;
  }

  Future<double> getCoinByIdPrice(String id) async {
    double price = 0.0;
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    if(box.isNotEmpty) {
     var date = box.values.where((coin) => coin.id == id);
      print("saveDats =  price = $date");
    }
    return price;
  }

  @override
  Future<List<CoinsModel>> showCoins() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CoinsModelAdapter());
    }
    final box = await Hive.openBox<CoinsModel>(COIN_BOX);
    var coins = box.values.toList();
    print(coins);
    return coins;
  }

  @override
  Future<void> saveWallets(List<WalletModel> listWallets) async {
    if (listWallets.isEmpty) return;
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalletModelAdapter());
    }
    final box = await Hive.openBox<WalletModel>(WALLET_BOX);
    await box.addAll(listWallets);
    print(listWallets);
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    if (wallet.name.isEmpty) return;
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalletModelAdapter());
    }

    final box = await Hive.openBox<WalletModel>(WALLET_BOX);
    final walletSave = WalletModel(name: wallet.name, link: wallet.link, id: wallet.id, droid: wallet.droid,
        blockchains: wallet.blockchains, sort: wallet.sort, ios: wallet.ios, walletType: wallet.walletType);
    await box.add(walletSave);
    print('walletSave::: $walletSave');
  }

  Future<List<WalletModel>> showWallet() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalletModelAdapter());
    }
    final box = await Hive.openBox<WalletModel>(WALLET_BOX);
    var wallets = box.values.toList();
    print(wallets);
    return wallets;
  }

  Future<List<WalletModel>> getWalletByNane(String name) async {
    var date;
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalletModelAdapter());
    }
    final box = await Hive.openBox<WalletModel>(WALLET_BOX);
    if(box.isNotEmpty) {
      date = box.values.where((wallet) => wallet.name == name).toList();
      print("saveDats =  date = $date");
    }
    return date;
  }
}

const String PROFILE_BOX = 'profile_box';
const String COIN_BOX = 'coin_box';
const String WALLET_BOX = 'wallet_box';
