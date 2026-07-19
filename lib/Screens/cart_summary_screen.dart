import 'package:beautyontapp/Screens/CheckoutWebView.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item.dart';

class CartSummaryScreen extends StatelessWidget {
  const CartSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width * 0.06;
    final c = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final items = c.items;
          final isEmpty = items.isEmpty;

          return ListView(
            padding: EdgeInsets.fromLTRB(pad, 18, pad, 24),
            children: [
              const Center(
                child: Text('Cart',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 18),

              if (isEmpty) ...[
                const SizedBox(height: 60),
                const Center(
                  child: Text('Your cart is empty',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
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
                    onPressed: Get.back,
                    child: const Text('CONTINUE SHOPPING',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // items list
              ...items.map((it) => _CartLine(item: it, c: c)).toList(),
              if (!isEmpty) const SizedBox(height: 16),

              // summary card
              if (!isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Summary',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('R ${c.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 24, color: Color(0xFFEDEDED)),
                      Row(
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text('R ${c.total.toStringAsFixed(2)} ZAR',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Taxes and shipping calculated at checkout',
                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: const [
                          Icon(Icons.local_shipping_outlined,
                              size: 18, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Estimate shipping',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.note_add_outlined,
                              size: 18, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Add order note',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: () {
                            print('[CartSummaryScreen] Check Out button pressed');
                            if (c.checkoutUrl != null && c.checkoutUrl!.isNotEmpty) {
                              Get.to(() => CheckoutWebView(url: c.checkoutUrl!));
                              print('[CartSummaryScreen] Navigated to CheckoutWebView with url: ${c.checkoutUrl}');
                            } else {
                              Get.snackbar('Error', 'No checkout URL available.', snackPosition: SnackPosition.BOTTOM);
                              print('[CartSummaryScreen] No checkoutUrl available');
                            }
                          },
                          child: const Text('CHECK OUT',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
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
}

class _CartLine extends StatelessWidget {
  final CartItem item;
  final CartController c;
  const _CartLine({required this.item, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl.isNotEmpty
                ? Image.network(
                    item.product.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 40),
                  )
                : (item.product.imageAsset.isNotEmpty
                    ? Image.asset(
                        item.product.imageAsset,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported, size: 40)),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((item.product.subtitle).isNotEmpty)
                  Text(item.product.subtitle.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                if ((item.product.subtitle).isNotEmpty) const SizedBox(height: 4),
                Text(item.product.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                if (item.variantTitle != null && item.variantTitle!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(item.variantTitle!,
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black54)),
                  ),
                const SizedBox(height: 10),
                Text('R ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => c.removeFromCart(item.lineId),
                icon: const Icon(Icons.delete_outline, color: Colors.black87),
                tooltip: 'Remove',
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _PillIcon(icon: Icons.remove, onTap: () => c.dec(item)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.qty}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  _PillIcon(icon: Icons.add, onTap: () => c.inc(item)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1F1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}