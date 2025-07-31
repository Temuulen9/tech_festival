class UpdateBalanceRequest {
  final String tag;
  final List<Map<String, dynamic>> value;

  UpdateBalanceRequest({
    required this.tag,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'value': value,
    };
  }
}

class BalanceValue {
  final String categoryId;
  final int count;

  BalanceValue({
    required this.categoryId,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'count': count,
    };
  }
}
