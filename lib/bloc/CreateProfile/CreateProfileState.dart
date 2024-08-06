
part of 'CreateProfileBloc.dart';

class CreateProfileState extends Equatable {

  // ignore: non_constant_identifier_names
  CreateProfileState(this.state, [List<String>? profile]) {
    this.profile = profile;
  }

  final CreateProfileStatus state;
  late final List<String>? profile;

  CreateProfileState copyWith(
      CreateProfileStatus status,
      [List<String>? profile]) {
    return CreateProfileState(status, profile);
  }

  @override
  List<Object> get props => [state];
}

enum CreateProfileStatus { start}