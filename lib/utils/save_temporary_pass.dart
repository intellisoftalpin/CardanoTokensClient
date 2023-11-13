import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import '../../utils/check_create_profile_time.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

saveTemporaryPass() {
  int pref = globals.passPrefer;
  if (pref == 0) {
    int? createDate =
        box.read('${globals.nameProfile + global.idProfile}create_time');
    int? enterDate =
        box.read('${globals.nameProfile + global.idProfile}enter_time');
    DateTime? profileCreateDate =
        DateTime.fromMillisecondsSinceEpoch(createDate!);
    DateTime? profileEnterDate =
        DateTime.fromMillisecondsSinceEpoch(enterDate!);
    if (createTimeCheck(profileCreateDate, profileEnterDate)) {
      box.write('${globals.nameProfile + global.idProfile}enter_time',
          DateTime.now().millisecondsSinceEpoch);
      box.write('${globals.nameProfile + global.idProfile}pass', globals.pass);
      print('DONE!!!!!!!');
    }
  }
}
