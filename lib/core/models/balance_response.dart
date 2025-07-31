class BalanceResponse {
  final bool success;
  final List<BalanceData>? data;

  BalanceResponse({
    required this.success,
    this.data,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => BalanceData.fromJson(item))
          .toList(),
    );
  }
}

class BalanceData {
  final String id;
  final String tag;
  final String categoryId;
  final String categoryName;
  final int totalAllowed;
  final int remaining;

  BalanceData({
    required this.id,
    required this.tag,
    required this.categoryId,
    required this.categoryName,
    required this.totalAllowed,
    required this.remaining,
  });

  factory BalanceData.fromJson(Map<String, dynamic> json) {
    return BalanceData(
      id: json['_id'],
      tag: json['tag'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      totalAllowed: json['total_allowed'],
      remaining: json['remaining'],
    );
  }
}
