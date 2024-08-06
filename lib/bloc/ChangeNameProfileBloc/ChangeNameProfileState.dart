part of 'ChangeNameProfileBloc.dart';

class ChangeNameProfileState extends Equatable {

  // ignore: non_constant_identifier_names
  ChangeNameProfileState(this.state, [List<String>? profile]) {
    this.profile = profile;
  }

  final ChangeNameProfileStatus state;
  late final List<String>? profile;

  ChangeNameProfileState copyWith(
      ChangeNameProfileStatus status,
      [List<String>? profile]
      ) {
    return ChangeNameProfileState(status, profile);
  }

  @override
  List<Object> get props => [state];
}

enum ChangeNameProfileStatus { start}