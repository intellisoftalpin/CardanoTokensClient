
part of 'DeleteProfileBloc.dart';

class DeleteProfileState extends Equatable {

  // ignore: non_constant_identifier_names
  DeleteProfileState(this.state, [List<ProfileModel>? profile]) {
    this.profile = profile;
  }

  final DeleteProfileStatus state;
  late final List<ProfileModel>? profile;

  DeleteProfileState copyWith(
      DeleteProfileStatus status,
      [List<ProfileModel>? profile]
      ) {
    return DeleteProfileState(status, profile);
  }

  @override
  List<Object> get props => [state];
}

enum DeleteProfileStatus { start}