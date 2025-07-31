import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_festival/core/api/api_client.dart';
import 'package:tech_festival/core/api/app_exception.dart';
import 'package:tech_festival/core/api/base_response.dart';
import 'package:tech_festival/core/utils/secure_storage.dart';
import 'package:tech_festival/core/utils/shared_pref.dart';
import 'package:tech_festival/screens/auth/bloc/auth_event.dart';
import 'package:tech_festival/screens/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialized()) {
    on<LoginEvent>(_onLoginEvent);
  }

  _onLoginEvent(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(LoginLoading());

      final response = await Api.client.post('/auth/login', data: {
        'user_name': event.username,
        'password': event.password,
      });

      final responseData = ApiBaseResponse.fromJson(response.data);
      if (responseData.success == true) {
        await SecStorage().write(
          key: SecStorageKeys.accessToken,
          value: response.data['data']['accessToken'],
        );

        await SharedPref.setRoleCode(
            role: response.data['data']['user']['role']);

        emit(LoginSuccess());
      } else {
        emit(LoginError(
          message: responseData.error ?? 'Хүсэлт амжилтгүй',
        ));
      }
    } catch (e) {
      emit(LoginError(message: handleException(e)));
    }
  }
}
