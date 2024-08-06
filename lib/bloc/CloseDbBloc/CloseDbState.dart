
import 'package:equatable/equatable.dart';


class CloseDbState extends Equatable {
  // ignore: non_constant_identifier_names
  CloseDbState(this.state) ;

  final CloseDbStatus state;


  CloseDbState copyWith(CloseDbStatus status) {
    return CloseDbState(status);
  }

  @override
  List<Object> get props => [state];
}

enum CloseDbStatus { close }
