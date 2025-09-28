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
  final c = Get.put(CartController()); // create or reuse

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
              // top bar (title + X)
              SizedBox(height: 18,),
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 8),
                child: Row(
                  children: [
                    const Text('Cart',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    // IconButton(
                    //   onPressed: Get.back,
                    //   icon: const Icon(Icons.close, color: Colors.black),
                    // ),
                  ],
                ),
              ),

              // content
              Expanded(
                child: isEmpty ? _EmptyCart(pad: pad) : _FilledCart(pad: pad, c: c),
              ),

              // bottom action buttons (only when items exist)
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
                              backgroundColor: const Color(0xFFE53935), // red
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              // TODO: push to a full cart/checkout page if you add later
                              Get.snackbar('Cart', 'Viewing cart…',
                                  snackPosition: SnackPosition.BOTTOM);
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
                            onPressed: () {
                              Get.snackbar('Checkout', 'Proceeding to checkout…',
                                  snackPosition: SnackPosition.BOTTOM);
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
}

class _EmptyCart extends StatelessWidget {
  final double pad;
  const _EmptyCart({required this.pad});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Get.back(), // go back and continue shopping
                child: const Text('CONTINUE SHOPPING',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledCart extends StatelessWidget {
  final CartController c;
  final double pad;
  const _FilledCart({required this.c, required this.pad});

  String _price(double v) => 'R ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 6, pad, 12),
      children: [
        // items
        ...c.items.map((it) => _CartRow(item: it, controller: c)).toList(),
        const SizedBox(height: 6),
        const Divider(height: 24, color: Color(0xFFEDEDED)),

        // totals
        Row(
          children: [
            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${_price(c.total)} ZAR',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Taxes and shipping calculated at checkout',
          style: TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        const SizedBox(height: 12),

        // small options
        Row(
          children: const [
            Icon(Icons.note_add_outlined, size: 18, color: Colors.black87),
            SizedBox(width: 8),
            Text('Add order note', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Icon(Icons.local_shipping_outlined, size: 18, color: Colors.black87),
            SizedBox(width: 8),
            Text('Estimate shipping', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 8),
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
          // thumb
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.product.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // text + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.variant != null) ...[
                  const SizedBox(height: 2),
                  Text(item.variant!,
                      style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                ],
                const SizedBox(height: 10),
                Text('R ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // delete + qty stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => controller.remove(item),
                icon: const Icon(Icons.delete_outline, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _QtyBtn(icon: Icons.remove, onTap: () => controller.dec(item)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.qty}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
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
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
