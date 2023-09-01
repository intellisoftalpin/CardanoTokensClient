part of 'ChangePassProfileBloc.dart';

abstract class ChangePassProfileEvent extends Equatable {
  const ChangePassProfileEvent();

  @override
  List<Object> get props => [];
}

class ChangePassProfile extends ChangePassProfileEvent {
  final String profile;
  final String nameProfile;
  final String pass;
  final String newProfilePath;
  final String newNameProfile;
  final String newProfilePass;
  final int passPref;

  const ChangePassProfile(
      {required this.profile,
        required this.nameProfile,
      required this.pass,
      required this.newProfilePath,
      required this.newNameProfile,
      required this.newProfilePass,
      required this.passPref});

  @override
  List<Object> get props => [profile];
}
