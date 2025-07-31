import 'package:equatable/equatable.dart';
import 'package:tech_festival/core/models/balance_response.dart';

abstract class BeweragesState extends Equatable {
  const BeweragesState();

  @override
  List<Object?> get props => [];
}

class BeweragesInitialized extends BeweragesState {}

class GetBeweragesLoading extends BeweragesState {}

class GetBeweragesSuccess extends BeweragesState {
  final List<BalanceData> bewerages;

  const GetBeweragesSuccess({required this.bewerages});

  @override
  List<Object?> get props => [bewerages];
}

class GetBeweragesError extends BeweragesState {
  final String message;

  const GetBeweragesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BewerageQuantityChanged extends BeweragesState {
  final BalanceData bewerage;
  final int quantity;

  const BewerageQuantityChanged({
    required this.bewerage,
    required this.quantity,
  });

  @override
  List<Object?> get props => [bewerage, quantity];
}

class UpdateBalanceLoading extends BeweragesState {}

class UpdateBalanceSuccess extends BeweragesState {}

class UpdateBalanceError extends BeweragesState {
  final String message;

  const UpdateBalanceError({required this.message});

  @override
  List<Object?> get props => [message];
}
