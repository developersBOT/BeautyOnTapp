import 'package:beautyontapp/Screens/CheckoutWebView.dart';
import 'package:beautyontapp/Screens/cart_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final c = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final isEmpty = c.items.isEmpty;
          return Column(
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 8),
                child: Row(
                  children: const [
                    Text('Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        )),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: isEmpty
                    ? _EmptyCart(pad: pad)
                    : _FilledCart(pad: pad, c: c),
              ),
              if (!isEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () async {
                              print('[CartScreen] View Cart button pressed');
                              if (c.cartId != null) {
                                await c.fetchCart(c.cartId!);
                                Get.to(() => const CartSummaryScreen());
                                print('[CartScreen] Navigated to CartSummaryScreen after fetch');
                              } else {
                                Get.snackbar('Error', 'No cart ID available. Please add an item first.', snackPosition: SnackPosition.BOTTOM);
                                print('[CartScreen] No cartId for View Cart');
                              }
                            },
                            child: const Text('VIEW CART',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () async {
                              print('[CartScreen] Check Out button pressed');
                              if (c.cartId != null) {
                                if (c.checkoutUrl == null || c.checkoutUrl!.isEmpty) {
                                  await c.fetchCart(c.cartId!);
                                  print('[CartScreen] Fetched cart for checkoutUrl');
                                }
                                if (c.checkoutUrl != null && c.checkoutUrl!.isNotEmpty) {
                                  Get.to(() => CheckoutWebView(url: c.checkoutUrl!));
                                  print('[CartScreen] Navigated to CheckoutWebView with url: ${c.checkoutUrl}');
                                } else {
                                  Get.snackbar('Error', 'No checkout URL available.', snackPosition: SnackPosition.BOTTOM);
                                  print('[CartScreen] No checkoutUrl after fetch');
                                }
                              } else {
                                Get.snackbar('Error', 'No cart ID available. Please add an item first.', snackPosition: SnackPosition.BOTTOM);
                                print('[CartScreen] No cartId for Check Out');
                              }
                            },
                            child: const Text('CHECK OUT',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // Widget for an empty cart
  Widget _EmptyCart({required double pad}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text('CONTINUE SHOPPING',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for a filled cart
  Widget _FilledCart({required double pad, required CartController c}) {
    String _price(double v) => 'R ${v.toStringAsFixed(2)}';

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 6, pad, 12),
      children: [
        ...c.items.map((it) => _CartRow(item: it, controller: c)).toList(),
        const SizedBox(height: 6),
        const Divider(height: 24, color: Color(0xFFEDEDED)),
        Row(
          children: [
            const Text('Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${_price(c.total)} ZAR',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final CartController controller;
  const _CartRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl.isNotEmpty
                ? Image.network(item.product.imageUrl,
                    width: 60, height: 60, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.variantTitle != null && item.variantTitle!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(item.variantTitle!,
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black54)),
                  ),
                const SizedBox(height: 10),
                Text('R ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => controller.removeFromCart(item.lineId),
                icon: const Icon(Icons.delete_outline, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _QtyBtn(icon: Icons.remove, onTap: () => controller.dec(item)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.qty}'),
                  ),
                  _QtyBtn(icon: Icons.add, onTap: () => controller.inc(item)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1F1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}