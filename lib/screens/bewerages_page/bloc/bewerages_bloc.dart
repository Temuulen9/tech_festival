import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_festival/core/api/api_client.dart';
import 'package:tech_festival/core/api/app_exception.dart';
import 'package:tech_festival/core/models/balance_response.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_event.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_state.dart';

class BeweragesBloc extends Bloc<BeweragesEvent, BeweragesState> {
  BeweragesBloc() : super(BeweragesInitialized()) {
    on<GetBeweragesEvent>(_onGetGetBeweragesEvent);
    on<ChangeBewerageQuantityEvent>(_onChangeBewerageQuantityEvent);
    on<UpdateBalanceEvent>(_onUpdateBalanceEvent);
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
      emit(GetBeweragesError(message: handleException(e)));
    }
  }

  _onChangeBewerageQuantityEvent(
    ChangeBewerageQuantityEvent event,
    Emitter<BeweragesState> emit,
  ) async {
    emit(
      BewerageQuantityChanged(
        bewerage: event.bewerage,
        quantity: event.quantity,
      ),
    );
  }

  _onUpdateBalanceEvent(
    UpdateBalanceEvent event,
    Emitter<BeweragesState> emit,
  ) async {
    try {
      emit(UpdateBalanceLoading());

      final response =
          await Api.client.put('/transaction/update-balance', data: {
        'tag': event.request.tag,
        'value': event.request.value,
      });

      if (response.statusCode == 200) {
        emit(UpdateBalanceSuccess());
      } else {
        emit(UpdateBalanceError(
          message: response.statusMessage ?? 'Хүсэлт амжилтгүй',
        ));
      }
    } catch (e) {
      emit(UpdateBalanceError(message: handleException(e)));
    }
  }
}
