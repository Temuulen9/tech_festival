import 'package:equatable/equatable.dart';

abstract class BeweragesEvent extends Equatable {
  const BeweragesEvent();

  @override
  List<Object?> get props => [];
}

class GetBeweragesEvent extends BeweragesEvent {
  final String tag;

  const GetBeweragesEvent({required this.tag});

  @override
  List<Object?> get props => [tag];
}
