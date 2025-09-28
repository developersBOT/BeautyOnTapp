import '../models/product.dart';

class CartItem {
  final Product product;
  final String? variant; // e.g. "30ml"
  int qty;

  CartItem({required this.product, this.variant, this.qty = 1});

  double get subTotal => product.price * qty;
}
