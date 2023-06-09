
part of 'ChangeNameProfileBloc.dart';

abstract class ChangeNameProfileEvent extends Equatable {
  const ChangeNameProfileEvent();

  @override
  List<Object> get props => [];
}


class ChangeNameProfile extends ChangeNameProfileEvent {
  final String profile;
  final String newProfile;
  const ChangeNameProfile({required this.profile, required this.newProfile});

  @override
  List<Object> get props => [profile];
}