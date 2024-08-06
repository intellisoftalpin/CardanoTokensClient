import 'package:equatable/equatable.dart';

abstract class AuthProfileEvent extends Equatable {
  const AuthProfileEvent();

  @override
  List<Object> get props => [];
}

class LoggedIn extends AuthProfileEvent {
  const LoggedIn();

  @override
  List<Object> get props => [];
}

class LoggedOut extends AuthProfileEvent {
  const LoggedOut();

  @override
  List<Object> get props => [];
}

class Logged extends AuthProfileEvent {
  const Logged();

  @override
  List<Object> get props => [];
}
