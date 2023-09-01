import 'package:crypto_offline/data/dbhive/CoinsModel.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';

import 'HivePrefProfileRepository.dart';
import 'WalletModel.dart';

final boxProfile = GetStorage('ProfileStorage');

Future<int> getPassPref(String idProfile) async {
  List<ProfileModel> profileList = [];
  int pref = 5;
  var habitJson = await boxProfile.read('profileList');
  if (habitJson == null) {
    profileList = [];
  } else {
    profileList = ProfileModel.decode(habitJson!);
  }
  if (profileList.isNotEmpty) {
    for (var data in profileList) {
      if (data.id == idProfile) {
        pref = data.pref!;
      }
    }
  }
  return pref;
}

class HivePrefProfileRepositoryImpl extends HivePrefProfileRepository {

  @override
  Future<List<ProfileModel>> deleteGroupFrom(
      String name, String idProfile) async {
    List<ProfileModel> profileList = [];
    int index = -1;
    var habitJson = await boxProfile.read('profileList');
    if (habitJson == null) {
      profileList = [];
    } else {
      profileList = ProfileModel.decode(habitJson!);
    }
    if (profileList.isNotEmpty) {
      for (int i = 0; i < profileList.length; i++) {
        if (profileList[i].id == idProfile) {
          index = i;
        }
      }
    }
    if (index != -1) {
      profileList.removeAt(index);
      await boxProfile.write('profileList', ProfileModel.encode(profileList));
      await boxProfile.save();
    }
    return profileList;
  }

  @override
  renameProfile(String name, String newName, String idProfile, int pref) async {
    List<ProfileModel> profileList = [];
    int index = -1;
    var habitJson = await boxProfile.read('profileList');
    if (habitJson == null) {
      profileList = [];
    } else {
      profileList = ProfileModel.decode(habitJson!);
    }
    if (profileList.isNotEmpty) {
      for (int i = 0; i < profileList.length; i++) {
        if (profileList[i].id == idProfile) {
          index = i;
        }
      }
    }
    if (index != -1) {
      ProfileModel newNamedProfile =
          ProfileModel(nameProfile: newName, id: idProfile, pref: pref);
      profileList[index] = newNamedProfile;
      await boxProfile.write('profileList', ProfileModel.encode(profileList));
      await boxProfile.save();
    }
  }

  @override
  saveProfile(String nameProfile, String idProfile, int pref) async {
    ProfileModel profile =
        ProfileModel(nameProfile: nameProfile, id: idProfile, pref: pref);
    try {
      List<ProfileModel> profileList = [];
      var habitJson = await boxProfile.read('profileList');
      if (habitJson == null) {
        profileList = [];
        profileList.add(profile);
        await boxProfile.write('profileList', ProfileModel.encode(profileList));
      } else {
        profileList = ProfileModel.decode(habitJson!);
        profileList.add(profile);
        await boxProfile.write('profileList', ProfileModel.encode(profileList));
      }
    } on Exception catch (e) {
      print(Error.safeToString(e));
    }
  }

  //@override
  //getProfile() async {
  //  try {
  //    List<ProfileModel> profileList = [];
  //    var habitJson = await boxProfile.read('profileList');
  //    if (habitJson == null) {
  //      profileList = [];
  //    } else {
  //      profileList = ProfileModel.decode(habitJson!);
  //    }
  //    return profileList;
  //  } on Exception catch (e) {
  //    print(Error.safeToString(e));
  //  }
  //}

  //@override
  //  Future<String> getProfileByName(String name) async {
  //  String profileId = '';
  //  try {
  //    if (!Hive.isAdapterRegistered(1)) {
  //      Hive.registerAdapter(ProfileModelAdapter());
  //    }
  //    final box = await Hive.openBox<ProfileModel>(PROFILE_BOX);
  //    if(box.isNotEmpty) {
  //      var profile = box.values.toList();
  //      for( var e in profile) {
  //        if(e.nameProfile == name) {
  //          profileId = e.id;
  //        }
  //      }
  //      print('PROFILES  profileId::::::::: $profileId');
  //    }
  //  } on Exception catch (e) {
  //    print(Error.safeToString(e));
  //  }
  //  return profileId;
  //}

  @override
  Future<List<ProfileModel>> showProfile() async {
    List<ProfileModel> profileList = [];
    var habitJson = await boxProfile.read('profileList');
    if (habitJson == null) {
      profileList = [];
    } else {
      profileList = ProfileModel.decode(habitJson!);
    }
    return profileList;
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
    if (box.isNotEmpty) {
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
    if (box.isNotEmpty) {
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
    final walletSave = WalletModel(
        name: wallet.name,
        link: wallet.link,
        id: wallet.id,
        droid: wallet.droid,
        blockchains: wallet.blockchains,
        sort: wallet.sort,
        ios: wallet.ios,
        walletType: wallet.walletType);
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
    if (box.isNotEmpty) {
      date = box.values.where((wallet) => wallet.name == name).toList();
      print("saveDats =  date = $date");
    }
    return date;
  }
}

const String PROFILE_BOX = 'profile_box';
const String COIN_BOX = 'coin_box';
const String WALLET_BOX = 'wallet_box';
