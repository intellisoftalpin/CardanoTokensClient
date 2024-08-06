part of 'ChangePassProfileBloc.dart';

class ChangePassProfileState extends Equatable {

  ChangePassProfileState(this.state, [List<String>? profile]) {
    this.profile = profile;
  }

  final ChangePassProfileStatus state;
  late final List<String>? profile;

  ChangePassProfileState copyWith(
      ChangePassProfileStatus status,
      [List<String>? profile]
      ) {
    return ChangePassProfileState(status, profile);
  }

  @override
  List<Object> get props => [state];
}

enum ChangePassProfileStatus {start}