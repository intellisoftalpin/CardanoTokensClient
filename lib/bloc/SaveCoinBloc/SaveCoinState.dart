
import 'package:equatable/equatable.dart';


class SaveCoinState extends Equatable {
  // ignore: non_constant_identifier_names
  SaveCoinState(this.state) ;

  final SaveCoinStatus state;


  SaveCoinState copyWith(SaveCoinStatus status) {
    return SaveCoinState(status);
  }

  @override
  List<Object> get props => [state];
}

enum SaveCoinStatus { save }

