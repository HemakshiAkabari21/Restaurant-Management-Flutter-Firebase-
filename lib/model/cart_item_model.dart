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

  factory CartItemModel.fromMap(Map<dynamic, dynamic> map) {
    return CartItemModel(
      productId: map['product_id'],
      productName: map['product_name'],
      productPrice: map['product_price'],
      qty: map['product_qty'],
      isHalf: map['is_half'],
      note: map['product_note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'product_price': productPrice,
    'product_qty': qty,
    'is_half': isHalf,
    'product_note': note,
  };
}
