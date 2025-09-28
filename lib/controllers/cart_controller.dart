import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();

  /// Reactive cart list
  final items = <CartItem>[].obs;

  /// Add item (merges by product + variant). Ignores qty < 1.
  void add(Product p, {String? variant, int qty = 1}) {
    if (qty < 1) return;
    final idx = items.indexWhere(
      (e) => e.product.id == p.id && e.variant == variant,
    );
    if (idx >= 0) {
      items[idx].qty += qty;
      items.refresh();
    } else {
      items.add(CartItem(product: p, variant: variant, qty: qty));
    }
  }

  /// Remove a specific CartItem
  void remove(CartItem it) => items.remove(it);

  /// Remove by product/variant (convenience)
  void removeBy(Product p, {String? variant}) {
    items.removeWhere((e) => e.product.id == p.id && e.variant == variant);
  }

  /// Increment/decrement helpers
  void inc(CartItem it) {
    it.qty++;
    items.refresh();
  }

  void dec(CartItem it) {
    if (it.qty > 1) {
      it.qty--;
      items.refresh();
    }
    // If you prefer removing when hitting 0, uncomment:
    // else { items.remove(it); }
  }

  /// Set quantity (clamps to >= 1)
  void setQty(CartItem it, int qty) {
    it.qty = qty < 1 ? 1 : qty;
    items.refresh();
  }

  /// Get current quantity for a product/variant (0 if not in cart)
  int qtyOf(Product p, {String? variant}) {
    final idx = items.indexWhere(
      (e) => e.product.id == p.id && e.variant == variant,
    );
    return idx < 0 ? 0 : items[idx].qty;
  }

  /// Totals & counts
  double get total => items.fold(0.0, (s, e) => s + e.subTotal);
  int get count  => items.fold(0, (s, e) => s + e.qty);

  /// Clear entire cart
  void clear() => items.clear();

  /// For quickly previewing the "filled cart" UI in development
  void seedDemo(List<CartItem> demo) {
    items
      ..clear()
      ..addAll(demo);
  }
}
