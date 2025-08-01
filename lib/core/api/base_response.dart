class ApiBaseResponse {
  bool? success;
  int? statusCode;
  Map<String, dynamic>? error;

  ApiBaseResponse({
    this.success,
    this.statusCode,
    this.error,
  });

  ApiBaseResponse.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    error = json['errors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['statusCode'] = statusCode;
    data['errors'] = error;
    return data;
  }

  @override
  String toString() => '''
    ApiBaseResponse { success: $success, statusCode: $statusCode, error: $error } 
    ''';
}
