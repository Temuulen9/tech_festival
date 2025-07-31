import 'package:equatable/equatable.dart';

abstract class NfcScannerState extends Equatable {
  const NfcScannerState();

  @override
  List<Object?> get props => [];
}

class NfcScannerInitialized extends NfcScannerState {}

class NfcRegisterLoading extends NfcScannerState {}

class NfcRegisterSuccess extends NfcScannerState {}

class NfcRegisterError extends NfcScannerState {
  final String message;

  const NfcRegisterError({required this.message});

  @override
  List<Object?> get props => [message];
}
