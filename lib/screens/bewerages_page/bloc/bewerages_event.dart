import 'package:equatable/equatable.dart';
import 'package:tech_festival/core/models/balance_response.dart';
import 'package:tech_festival/core/models/update_balance_request.dart';

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

class ChangeBewerageQuantityEvent extends BeweragesEvent {
  final BalanceData bewerage;
  final int quantity;

  const ChangeBewerageQuantityEvent({
    required this.bewerage,
    required this.quantity,
  });

  @override
  List<Object?> get props => [bewerage, quantity];
}

class UpdateBalanceEvent extends BeweragesEvent {
  final UpdateBalanceRequest request;

  const UpdateBalanceEvent({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}
