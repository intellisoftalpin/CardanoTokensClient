
part of 'CloseDbBloc.dart';

abstract class CloseDbEvent extends Equatable {
  const CloseDbEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfile extends CloseDbEvent {
  final String idProfile;
  const UpdateProfile({required this.idProfile});

  @override
  List<Object> get props => [idProfile];
}
