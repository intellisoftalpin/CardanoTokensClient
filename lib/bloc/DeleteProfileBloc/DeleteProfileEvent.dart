
part of 'DeleteProfileBloc.dart';

abstract class DeleteProfileEvent extends Equatable {
  const DeleteProfileEvent();

  @override
  List<Object> get props => [];
}


class DeleteProfile extends DeleteProfileEvent {
  final String profile;
  final String idProfile;
  const DeleteProfile({required this.profile, required this.idProfile});

  @override
  List<Object> get props => [profile, idProfile];
}