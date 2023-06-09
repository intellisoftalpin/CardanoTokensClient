
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;
import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/DbRepository/DbRepository.dart';

import 'CloseDbState.dart';

part 'CloseDbEvent.dart';


class CloseDbBloc extends Bloc<CloseDbEvent, CloseDbState> {
  final DbRepository _dbRepository;
  String newIdProfile;
  CloseDbBloc(this._dbRepository, this.newIdProfile)
      : super(CloseDbState(CloseDbStatus.close)) {
    add(UpdateProfile(idProfile: newIdProfile));
  }

  @override
  Stream<CloseDbState> mapEventToState(CloseDbEvent event) async* {
    if (event is UpdateProfile) {
      newIdProfile = event.idProfile;
      yield* _getSwitch(event);
    }
  }

  Stream<CloseDbState> _getSwitch(CloseDbEvent event) async* {
    if(newIdProfile.isNotEmpty && globals.pass.isNotEmpty || newIdProfile != '' && globals.pass != '') {
      await _dbRepository.closeDb(newIdProfile, globals.pass);
      // global.idProfile = newIdProfile;
      print(" ::::::: newIdProfile = $newIdProfile newNameProfile = ${globals.nameProfile} "
          "global.idProfile = ${global.idProfile}");

      globals.pass = '';
    }
  }

}
