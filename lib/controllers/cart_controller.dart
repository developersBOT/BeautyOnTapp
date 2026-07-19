import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'package:get_storage/get_storage.dart'; // For persistent storage

class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();

  /// Reactive cart list
  final items = <CartItem>[].obs;

  /// Cart ID from server (nullable, generated on first add) - String for GID
  String? cartId;

  /// Checkout URL from server
  String? checkoutUrl;

  // Persistent storage using GetStorage
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Load saved cartId from storage (if available)
    cartId = _storage.read('cartId');
    print('[CartController] Loaded cartId from storage: $cartId');
  }

  // Fetch cart from the server (using cartId)
  Future<void> fetchCart(String cartId) async {
    try {
      print('[CartController] Fetching cart with ID: $cartId');
      final response = await ProductService.fetchCart(cartId);

      if (response != null && response['success'] == true && response['data'] != null) {
        // Save local variant to imageUrl and price map to preserve from local adds
        Map<String, String> variantToImage = {};
        Map<String, double> variantToPrice = {};
        for (var item in items) {
          if (item.variant.isNotEmpty) {
            if (item.product.imageUrl.isNotEmpty) {
              variantToImage[item.variant] = item.product.imageUrl;
            }
            if (item.product.price > 0) {
              variantToPrice[item.variant] = item.product.price;
            }
          }
        }

        items.clear();  // Clear the current cart
        final cartItems = response['data']['cart_items'] as List? ?? [];
        List<CartItem> newItems = cartItems.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();

        // Merge preserved images and prices into fetched items if missing
        for (int i = 0; i < newItems.length; i++) {
          final item = newItems[i];
          String? newImageUrl = item.product.imageUrl;
          double newPrice = item.product.price;
          if (newImageUrl.isEmpty && variantToImage.containsKey(item.variant)) {
            newImageUrl = variantToImage[item.variant]!;
          }
          if (newPrice == 0.0 && variantToPrice.containsKey(item.variant)) {
            newPrice = variantToPrice[item.variant]!;
          }
          if (newImageUrl != item.product.imageUrl || newPrice != item.product.price) {
            // Create new Product with preserved values
            final updatedProduct = Product(
              id: item.product.id,
              title: item.product.title,
              subtitle: item.product.subtitle,
              imageAsset: item.product.imageAsset,
              imageUrl: newImageUrl ?? '',
              price: newPrice,
              rating: item.product.rating,
              reviews: item.product.reviews,
            );
            // Replace with new CartItem
            newItems[i] = CartItem(
              product: updatedProduct,
              variant: item.variant,
              variantTitle: item.variantTitle,
              qty: item.qty,
              lineId: item.lineId,
            );
          }
        }

        items.addAll(newItems);
        checkoutUrl = response['data']['checkout_url'] as String?;
        print('[CartController] Fetched cart items: ${items.length}, checkoutUrl: $checkoutUrl');
      } else {
        print('[CartController] Failed to fetch cart - Response invalid');
        Get.snackbar('Error', 'Failed to fetch cart', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('[CartController] Error fetching cart: $e');
      Get.snackbar('Error', 'Failed to fetch cart details', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Add item to server cart and local list
  Future<void> addToCart(String variantId, int qty, Product product, {String? variantTitle}) async {
    if (qty < 1) return;

    print('[CartController] Adding to cart - Variant ID: $variantId, Quantity: $qty, Variant Title: $variantTitle');

    try {
      Map<String, dynamic>? response;
      String? lineItemId;
      if (cartId == null) {
        print('[CartController] No cart ID, creating new cart with initial item...');
        response = await ProductService.createCart(variantId: variantId, qty: qty);
      } else {
        print('[CartController] Existing cart ID: $cartId, adding item...');
        response = await ProductService.addToCart(
          cartId: cartId!,
          variantId: variantId,
          qty: qty,
        );
      }

      if (response != null && response['success'] == true) {
        print('[CartController] Successfully added to cart: $response');

        // Update cartId from server response if provided
        if (response['cart_id'] != null) {
          cartId = response['cart_id'].toString(); // Already stripped in service
          if (cartId != null) {
            _storage.write('cartId', cartId);
            print('[CartController] Cart ID updated: $cartId');
          }
        }

        lineItemId = response['line_item_id']?.toString();

        final idx = items.indexWhere(
          (e) => e.product.id == product.id && e.variant == variantId,
        );

        if (idx >= 0) {
          items[idx].qty += qty;
          items.refresh();
        } else {
          items.add(CartItem(
            product: product,
            variant: variantId,
            variantTitle: variantTitle,
            qty: qty,
            lineId: lineItemId,
          ));
        }

        Get.snackbar('Success', 'Added to cart successfully', snackPosition: SnackPosition.BOTTOM);
        
        // Navigate to cart screen after successful add
        Get.toNamed('/cart');
      } else {
        print('[CartController] Failed to add to cart - API error');
        Get.snackbar('Error', 'Failed to add item to cart', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('[CartController] Error in addToCart: $e');
      Get.snackbar('Error', 'An error occurred while adding to cart', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Get cartId from session (GetStorage)
  String? getCartIdFromSession() {
    return _storage.read('cartId');
  }

  /// Save cartId to session (GetStorage)
  void saveCartIdToSession(String cartId) {
    _storage.write('cartId', cartId);
  }

  /// Remove a specific CartItem by its lineId (or product/variant)
  void removeFromCart(String? lineId) {
    if (lineId == null) return;
    final itemIndex = items.indexWhere((item) => item.lineId == lineId);
    if (itemIndex >= 0) {
      items.removeAt(itemIndex);
      print('[CartController] Removed item with lineId: $lineId');
    }
  }

  /// Increment item quantity
  void inc(CartItem it) {
    it.qty++;
    items.refresh(); // Refresh the list
    print('[CartController] Incremented qty for ${it.product.title} to ${it.qty}');
  }

  /// Decrement item quantity (at least 1)
  void dec(CartItem it) {
    if (it.qty > 1) {
      it.qty--;
      items.refresh(); // Refresh the list
      print('[CartController] Decremented qty for ${it.product.title} to ${it.qty}');
    }
  }

  /// Total of the items in the cart
  double get total => items.fold(0.0, (s, e) => s + (e.product.price * e.qty));

  /// Count of the items in the cart
  int get count => items.fold(0, (s, e) => s + e.qty);

  /// Clear entire cart
  void clear() => items.clear();

  /// For quickly previewing the "filled cart" UI in development
  void seedDemo(List<CartItem> demo) {
    items..clear()..addAll(demo);
  }
}