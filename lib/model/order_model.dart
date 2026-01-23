import 'package:restaurant_management_fierbase/model/cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final int isGst;
  final DateTime orderDate;
  final double orderTotal;
  final OrderJson orderJson;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.isGst,
    required this.orderDate,
    required this.orderTotal,
    required this.orderJson,
  });

  // FROM MAP (Firebase → Model)
  factory OrderModel.fromMap(String orderId, Map<String, dynamic> map) {
    return OrderModel(
      orderId: orderId,
      customerName: map['customer_name'] ?? '',
      customerMobile: map['customer_mobile'] ?? '',
      customerEmail: map['customer_email'] ?? '',
      isGst: map['is_gst'] ?? 0,
      orderDate: DateTime.parse(map['order_date']),
      orderTotal: double.parse(map['order_total'].toString()),
      orderJson: OrderJson.fromMap(
        Map<String, dynamic>.from(map['order_json']),
      ),
    );
  }

  // TO MAP (Model → Firebase)
  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'customer_email': customerEmail,
      'is_gst': isGst,
      'order_date': orderDate.toIso8601String(),
      'order_total': orderTotal,
      'order_json': orderJson.toMap(),
    };
  }

  // COPY WITH
  OrderModel copyWith({
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    int? isGst,
    DateTime? orderDate,
    double? orderTotal,
    OrderJson? orderJson,
  }) {
    return OrderModel(
      orderId: orderId,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      customerEmail: customerEmail ?? this.customerEmail,
      isGst: isGst ?? this.isGst,
      orderDate: orderDate ?? this.orderDate,
      orderTotal: orderTotal ?? this.orderTotal,
      orderJson: orderJson ?? this.orderJson,
    );
  }
}


class OrderJson {
  final List<CartItemModel> items;
  final double subTotal;
  final double gstPercent;
  final double gstAmount;
  final double serviceCharge;
  final double discount;
  final double grandTotal;

  OrderJson({
    required this.items,
    required this.subTotal,
    required this.gstPercent,
    required this.gstAmount,
    required this.serviceCharge,
    required this.discount,
    required this.grandTotal,
  });

  factory OrderJson.fromMap(Map<String, dynamic> map) {
    return OrderJson(
      items: (map['items'] as List)
          .map((e) => CartItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      subTotal: double.parse(map['sub_total'].toString()),
      gstPercent: double.parse(map['gst_percent'].toString()),
      gstAmount: double.parse(map['gst_amount'].toString()),
      serviceCharge: double.parse(map['service_charge'].toString()),
      discount: double.parse(map['discount'].toString()),
      grandTotal: double.parse(map['grand_total'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((e) => e.toMap()).toList(),
      'sub_total': subTotal,
      'gst_percent': gstPercent,
      'gst_amount': gstAmount,
      'service_charge': serviceCharge,
      'discount': discount,
      'grand_total': grandTotal,
    };
  }

  OrderJson copyWith({
    List<CartItemModel>? items,
    double? subTotal,
    double? gstPercent,
    double? gstAmount,
    double? serviceCharge,
    double? discount,
    double? grandTotal,
  }) {
    return OrderJson(
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      gstPercent: gstPercent ?? this.gstPercent,
      gstAmount: gstAmount ?? this.gstAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }
}

