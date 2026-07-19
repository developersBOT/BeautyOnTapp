import '../models/product.dart';

class CartItem {
  final Product product;
  final String variant;
  final String? variantTitle;
  int qty;  // Removed 'final' so it can be modified
  final String? lineId;

  CartItem({
    required this.product,
    required this.variant,
    this.variantTitle,
    required this.qty,
    this.lineId,
  });

  // Add the fromJson method
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      variant: json['variant'] ?? '',
      variantTitle: json['variant_title'] ?? '',
      qty: json['qty'] ?? 1,
      lineId: json['line_id'],
    );
  }
}