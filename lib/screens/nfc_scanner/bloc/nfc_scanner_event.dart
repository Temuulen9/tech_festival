import 'package:equatable/equatable.dart';

abstract class NfcScannerEvent extends Equatable {
  const NfcScannerEvent();

  @override
  List<Object?> get props => [];
}

class RegisterNfc extends NfcScannerEvent {
  final String serialNumber;

  const RegisterNfc({
    required this.serialNumber,
  });

  @override
  List<Object?> get props => [serialNumber];
}
