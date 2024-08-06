
part of 'CreateProfileBloc.dart';

abstract class CreateProfileEvent extends Equatable {
  const CreateProfileEvent();

  @override
  List<Object> get props => [];
}

class SaveProfile extends CreateProfileEvent {
  final String profile;
  final String idProfile;
  final String pass;
  final int passPrefer;
  const SaveProfile({required this.profile, required this.idProfile, required this.pass, required this.passPrefer});

  @override
  List<Object> get props => [profile];
}

