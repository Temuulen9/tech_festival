import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_festival/core/api/api_client.dart';
import 'package:tech_festival/core/api/app_exception.dart';
import 'package:tech_festival/core/api/base_response.dart';
import 'package:tech_festival/screens/nfc_scanner/bloc/nfc_scanner_event.dart';
import 'package:tech_festival/screens/nfc_scanner/bloc/nfc_scanner_state.dart';

class NfcScannerBloc extends Bloc<NfcScannerEvent, NfcScannerState> {
  NfcScannerBloc() : super(NfcScannerInitialized()) {
    on<RegisterNfc>(_onRegisterNfc);
  }

  _onRegisterNfc(
    RegisterNfc event,
    Emitter<NfcScannerState> emit,
  ) async {
    try {
      emit(NfcRegisterLoading());

      final response = await Api.client.post('/nfc/create', data: {
        'tag': event.serialNumber,
      });

      final responseData = ApiBaseResponse.fromJson(response.data);
      if (responseData.success == true) {
        emit(NfcRegisterSuccess());
      } else {
        emit(NfcRegisterError(
          message: responseData.error?['message'] ?? 'Хүсэлт амжилтгүй',
        ));
      }
    } catch (e) {
      emit(NfcRegisterError(message: handleException(e)));
    }
  }
}
