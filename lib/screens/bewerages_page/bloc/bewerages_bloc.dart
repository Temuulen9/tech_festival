import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_festival/core/api/api_client.dart';
import 'package:tech_festival/core/api/app_exception.dart';
import 'package:tech_festival/core/models/balance_response.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_event.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_state.dart';

class BeweragesBloc extends Bloc<BeweragesEvent, BeweragesState> {
  BeweragesBloc() : super(BeweragesInitialized()) {
    on<GetBeweragesEvent>(_onGetGetBeweragesEvent);
  }

  _onGetGetBeweragesEvent(
    GetBeweragesEvent event,
    Emitter<BeweragesState> emit,
  ) async {
    try {
      emit(GetBeweragesLoading());

      // final responseCreateTag =
      //     await Api.client.post('/transaction/create-tag', data: {
      //   'tag': event.tag,
      // });

      // if (responseCreateTag.statusCode != 200) {
      //   emit(GetBeweragesError(
      //     message: responseCreateTag.statusMessage ?? 'Хүсэлт амжилтгүй',
      //   ));
      //   return;
      // }

      final response = await Api.client
          .get('/transaction/get-balance/${Uri.encodeComponent(event.tag)}');
      final responseData = BalanceResponse.fromJson(response.data);
      if (responseData.success) {
        emit(GetBeweragesSuccess(bewerages: responseData.data ?? []));
      } else {
        emit(GetBeweragesError(
          message: response.statusMessage ?? 'Хүсэлт амжилтгүй',
        ));
      }
    } catch (e) {
      if (e is DioException) {
        emit(GetBeweragesError(message: handleException(e)));
      }
    }
  }
}
