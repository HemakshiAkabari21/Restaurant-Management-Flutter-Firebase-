class CartItemModel {
  final String productId;
  final String productName;
  final double productPrice;
  final int productQty;
  final int isHalf;
  final String productNote;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productQty,
    required this.isHalf,
    required this.productNote,
  });

  /// Firebase → Model (SAFE)
  factory CartItemModel.fromMap(Map map) {
    final data = Map<String, dynamic>.from(map);

    return CartItemModel(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      productPrice: (data['product_price'] as num?)?.toDouble() ?? 0.0,
      productQty: data['product_qty'] ?? 0,
      isHalf: data['is_half'] ?? 0,
      productNote: data['product_note'] ?? '',
    );
  }

  /// Model → Firebase
  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'product_price': productPrice,
    'product_qty': productQty,
    'is_half': isHalf,
    'product_note': productNote,
  };

  /// COPY WITH
  CartItemModel copyWith({
    String? productId,
    String? productName,
    double? productPrice,
    int? qty,
    int? isHalf,
    String? note,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productQty: qty ?? this.productQty,
      isHalf: isHalf ?? this.isHalf,
      productNote: note ?? this.productNote,
    );
  }
}
