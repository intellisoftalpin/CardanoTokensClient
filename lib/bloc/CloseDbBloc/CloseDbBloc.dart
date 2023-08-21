
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;
import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/DbRepository/DbRepository.dart';

import 'CloseDbState.dart';

part 'CloseDbEvent.dart';


class CloseDbBloc extends Bloc<CloseDbEvent, CloseDbState> {
  final DbRepository _dbRepository;
  String idProfile;
  CloseDbBloc(this._dbRepository, this.idProfile)
      : super(CloseDbState(CloseDbStatus.close)) {
    add(UpdateProfile(idProfile: idProfile));
  }

  @override
  Stream<CloseDbState> mapEventToState(CloseDbEvent event) async* {
    if (event is UpdateProfile) {
      idProfile = event.idProfile;
      yield* _getSwitch(event);
    }
  }

  Stream<CloseDbState> _getSwitch(CloseDbEvent event) async* {
    if(idProfile.isNotEmpty && globals.pass.isNotEmpty || idProfile != '' && globals.pass != '') {
      await _dbRepository.closeDb(idProfile, globals.pass);
      // global.idProfile = newIdProfile;
      print(" ::::::: newIdProfile = $idProfile newNameProfile = ${globals.nameProfile} "
          "global.idProfile = ${global.idProfile}");

      globals.pass = '';
    }
  }

}
