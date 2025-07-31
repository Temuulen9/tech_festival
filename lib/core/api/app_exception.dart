import 'package:dio/dio.dart';
import 'package:tech_festival/core/api/base_response.dart';

String handleException(ex) {
  try {
    if (ex is DioException) {
      if (ex.response?.data != null) {
        // Default
        final baseResponse = ApiBaseResponse.fromJson(ex.response?.data);
        return baseResponse.error ?? 'Хүсэлт амжилтгүй.';
      } else {
        // Handle specific Dio error types
        switch (ex.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            return 'Холболтын хугацаа дууслаа.';
          case DioExceptionType.badCertificate:
            return 'Баталгаажуулалтын алдаа.';
          case DioExceptionType.connectionError:
            return 'Интернэт холболтоо шалгана уу.';
          case DioExceptionType.cancel:
            return 'Хүсэлт цуцлагдлаа.';
          case DioExceptionType.badResponse:
            return 'Алдаатай хариу.';
          case DioExceptionType.unknown:
            if (ex.message?.contains('SocketException') ?? false) {
              return 'Интернэт холболтоо шалгана уу.';
            } else {
              return 'Хүсэлт амжилтгүй';
            }
        }
      }
    } else {
      return 'Алдаа гарлаа';
    }
  } catch (ex) {
    return 'Алдаа гарлаа';
  }
}

String handleError(ApiBaseResponse responseData) {
  if (responseData.error != '') {
    return responseData.error!;
  } else {
    return 'Хүсэлт амжилтгүй';
  }
}
