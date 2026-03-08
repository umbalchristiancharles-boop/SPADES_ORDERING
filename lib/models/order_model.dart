// ============================================================================
// ORDER MODEL
// ============================================================================

class OrderModel {
  final String id;
  final Map<int, int> items;
  final double total;
  final DateTime date;
  final String status;
  final String? deliveryArea;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Pending',
    this.deliveryArea,
  });

  OrderModel copyWith({
    String? id,
    Map<int, int>? items,
    double? total,
    DateTime? date,
    String? status,
    String? deliveryArea,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      date: date ?? this.date,
      status: status ?? this.status,
      deliveryArea: deliveryArea ?? this.deliveryArea,
    );
  }
}

