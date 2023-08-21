import 'dart:convert';
import 'dart:io';

import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/utils/random_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

import '../../data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;

import '../../data/model/CardanoModel.dart';
import '../../data/repository/ApiRepository/ApiRepository.dart';
import '../../domain/entities/CoinEntity.dart';
import '../../domain/entities/TransactionEntity.dart';
import '../../utils/backup_restore.dart';
import '../../utils/file_manager.dart';

part 'CreateProfileEvent.dart';

part 'CreateProfileState.dart';

String idProfile = '';

class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final HivePrefProfileRepository _hiveProfileRepository;
  final DbRepository _dbRepository;
  String profile;
  String oldIdProfile;
  String? newProfileId;
  String pass;
  int passPrefer;
  String? idDBProf;

  CreateProfileBloc(
      this._dbRepository,
      this._hiveProfileRepository,
      this.profile,
      this.oldIdProfile,
      this.newProfileId,
      this.pass,
      this.passPrefer,
      this.idDBProf)
      : super(CreateProfileState(CreateProfileStatus.start)) {
    add(SaveProfile(profile: '', idProfile: '', pass: '', passPrefer: 0));
  }

  @override
  Stream<CreateProfileState> mapEventToState(CreateProfileEvent event) async* {
    if (event is SaveProfile) {
      yield* _saveProfile(event);
    }
  }

  Stream<CreateProfileState> _saveProfile(CreateProfileEvent event) async* {
    print('idDBProf::::$idDBProf');
    try {
      if (profile.isNotEmpty && pass.isNotEmpty ||
          profile != '' && pass != '' && profile != 'null') {
        final box = GetStorage('PassPrefer');
        String prof = globals.nameProfile.trim() + "+true";
        print(
            ":::::::::CreateBloc  prof = $prof, profile= $profile :::::: profile == prof ${profile == prof}");
        if (profile == prof && newProfileId != null) {
          var newIdProfile = newProfileId!;
          var newPort = globals.nameProfile;

          print(":::::prof = ${await _hiveProfileRepository.showProfile()}");
          await _hiveProfileRepository.saveProfile(newPort, newIdProfile);
          print("profile= $profile, idProfile = $oldIdProfile, pass = $pass");
          print(":::::profiles= ${await _hiveProfileRepository.showProfile()}");

          box.remove(globals.nameProfile + oldIdProfile);
          box.write(newPort + newIdProfile, passPrefer);
          print("edit_alert pref = $passPrefer");
          if (passPrefer == 0) {
            box.remove('${globals.nameProfile + oldIdProfile}pass');
            box.write('${newPort + newIdProfile}pass', pass.trim());
          }
          print(
              " :::::: oldIdProfile = $oldIdProfile, +  ${globals.nameProfile}, "
              "createDate = ${box.read('${globals.nameProfile.trim() + oldIdProfile}create_time')}");
          int createDate = box
              .read('${globals.nameProfile.trim() + oldIdProfile}create_time');
          int enterDate = box
              .read('${globals.nameProfile.trim() + oldIdProfile}enter_time');
          box.remove('${globals.nameProfile.trim() + oldIdProfile}create_time');
          box.remove('${globals.nameProfile.trim() + oldIdProfile}enter_time');
          box.write('${newPort + newIdProfile}create_time', createDate);
          box.write('${newPort + newIdProfile}enter_time', enterDate);
          box.write(newPort + newIdProfile, passPrefer);

          List<FileSystemEntity> listFiles = [];
          String idProfile = oldIdProfile;
          idProfile = idProfile.replaceAll("/", "*");
          print("idProfile = $idProfile");
          final zipFiles = "/zipFile/$idProfile";
          try {
            listFiles = await BackupRestore.getFilesFromDir(zipFiles);

            if (listFiles.isNotEmpty) {
              print("list_recovery_to_delete = $listFiles");
              for (var data in listFiles) {
                try {
                  final dir = Directory(data.path);
                  idProfile = idProfile.replaceAll("/", "*");
                  final zipFiles = "/zipFile/$idProfile";

                  dir.deleteSync(recursive: true);
                  print("zipPath = ${data.path}");

                  listFiles = await BackupRestore.getFilesFromDir(zipFiles);
                  print("list = $listFiles");
                } on Exception catch (e) {
                  print("Exception_backup: $e");
                }
              }
              print("list_recovery_after_delete = $listFiles");
            } else {
              print("listFiles isNotEmpty");
            }
          } on Exception catch (e) {
            print("Exception_backup: $e");
          }

          yield state.copyWith(CreateProfileStatus.start);
        } else {
          if (idDBProf != null) {
            ApiRepository _apiRepository = ApiRepository();
            var internet = await _apiRepository.check();
            List<Tokens> cardanoList = [];
            if (internet) {
              Response responseCardano =
                  await _apiRepository.getCardanoTokensList();
              try {
                int statusCardano = responseCardano.statusCode;
                if (statusCardano == HttpStatus.ok) {
                  Map data = jsonDecode(responseCardano.body);
                  cardanoList = (data["tokens"] as List)
                      .map((e) => Tokens.fromJson(e))
                      .cast<Tokens>()
                      .toList();
                } else {
                  print('http error');
                }
              } on Exception catch (e) {
                print('Exception::: $e');
              }
              String idProf = idDBProf!;
              idProfile = idProf;
              print("RECOVERY_BLOC:::profile= $profile, idProfile = $idProf");
              await _hiveProfileRepository.saveProfile(profile, idProfile);
              await _dbRepository.openDb(idProfile, pass);
              List<TransactionEntity> transactions =
                  await _dbRepository.getAllTransaction();
              for (var cardano in cardanoList) {
                for (var trans in transactions) {
                  if (cardano.tokenId == trans.coinId) {
                    CoinEntity coinEntity = CoinEntity(
                        coinId: cardano.tokenId!,
                        name: cardano.name!,
                        symbol: cardano.assetName!,
                        image:
                            'https://ctokens.io/api/v1/tokens/images/${cardano.policyId}.${cardano.assetId}.png',
                        currentPrice: cardano.priceUsd!,
                        percentChange24h: cardano.priceTrend24h,
                        percentChange7d: cardano.priceTrend7d,
                        marketCap: cardano.capUsd!.toInt(),
                        rank: cardano.decimals,
                        price: cardano.priceUsd!,
                        adaPrice: cardano.priceAda!,
                        liquidAda: cardano.liquidAda!,
                        isRelevant: 1);
                    await _hiveProfileRepository.saveCoinId(coinEntity.coinId);
                    await FileManager.saveCoinById(
                        coinEntity.coinId, coinEntity.toDatabaseJson());
                  }
                }
              }
              box.write(profile + idProf, passPrefer);
              if (passPrefer == 0) {
                box.write('${profile + idProf}pass', pass.trim());
              }
              DateTime now = DateTime.now();
              int createTime = now.millisecondsSinceEpoch;
              int enterTime = now.millisecondsSinceEpoch;
              box.write('${profile + idProf}create_time', createTime);
              box.write('${profile + idProf}enter_time', enterTime);

              yield state.copyWith(CreateProfileStatus.start);
            }
          } else {
            String idProf = await getIdProf();
            idProfile = idProf;
            print("profile= $profile, idProfile = $idProf");
            await _hiveProfileRepository.saveProfile(profile, idProfile);
            await _dbRepository.openDb(idProfile, pass);

            box.write(profile + idProf, passPrefer);
            if (passPrefer == 0) {
              box.write('${profile + idProf}pass', pass.trim());
            }
            DateTime now = DateTime.now();
            int createTime = now.millisecondsSinceEpoch;
            int enterTime = now.millisecondsSinceEpoch;
            box.write('${profile + idProf}create_time', createTime);
            box.write('${profile + idProf}enter_time', enterTime);

            yield state.copyWith(CreateProfileStatus.start);
          }
        }
      }
    } on Exception catch (e) {
      print(Error.safeToString(e));
      print("Exception $e");
    }
  }

  Future<String> getIdProf() async {
    String idProf = RandomString.getRandomString(10);
    List<ProfileModel> listProfile = await _hiveProfileRepository.showProfile();
    if (listProfile.isNotEmpty) {
      for (var profile in listProfile) {
        if (idProf == profile.id) {
          idProf = RandomString.getRandomString(10);
        }
      }
    }
    return idProf;
  }
}
