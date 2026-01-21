class CartItemModel {
  final String productId;
  final String productName;
  final String productPrice;
  final int qty;
  final int isHalf;
  final String note;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.qty,
    required this.isHalf,
    required this.note,
  });

  /// Firebase → Model
  factory CartItemModel.fromMap(Map<dynamic, dynamic> map) {
    return CartItemModel(
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      productPrice: map['product_price'] ?? '0',
      qty: map['product_qty'] ?? 0,
      isHalf: map['is_half'] ?? 0,
      note: map['product_note'] ?? '',
    );
  }

  /// Model → Firebase
  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'product_price': productPrice,
    'product_qty': qty,
    'is_half': isHalf,
    'product_note': note,
  };

  ///  COPY WITH (IMPORTANT)
  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? productPrice,
    int? qty,
    int? isHalf,
    String? note,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      qty: qty ?? this.qty,
      isHalf: isHalf ?? this.isHalf,
      note: note ?? this.note,
    );
  }
}
