import 'package:flutter/material.dart';

class SkinAnalysisDetailScreen extends StatefulWidget {
  const SkinAnalysisDetailScreen({super.key});

  @override
  State<SkinAnalysisDetailScreen> createState() => _SkinAnalysisDetailScreenState();
}

class _SkinAnalysisDetailScreenState extends State<SkinAnalysisDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double pad = size.width * 0.07;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Image.asset(
              "assets/images/book1.png", // your big product image
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              "BeautyOnTApp",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              "Skin Analysis",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Wishlist + Rating
            Row(
              children: const [
                Icon(Icons.favorite_border, size: 20, color: Colors.black),
                SizedBox(width: 6),
                Text("Not in Wishlist",
                    style: TextStyle(fontSize: 12.5, color: Colors.black87)),
                Spacer(),
                Icon(Icons.star, color: Colors.black, size: 18),
                Icon(Icons.star, color: Colors.black, size: 18),
                Icon(Icons.star, color: Colors.black, size: 18),
                Icon(Icons.star, color: Colors.black, size: 18),
                Icon(Icons.star_half, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Text("(38)",
                    style: TextStyle(fontSize: 12.5, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),

            // Price
            Row(
              children: const [
                Text(
                  "R 220.00",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "R 400.00",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "SAVE 45%",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Book an Appointment",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "ADD TO CART",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Description",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your Skin, Scientifically Understood",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // You may also like
            const Text(
              "You may also like",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: size.height * 0.28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ProductCard(
                      "assets/images/new_arrival_1.png", "Niacinamide Body Mist", "R 385.00"),
                  _ProductCard(
                      "assets/images/new_arrival_2.png", "Niacinamide SPF50 Sunscreen", "R 465.00"),
                  _ProductCard(
                      "assets/images/offer1.png", "Pimple Cream", "R 120.00"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Recently viewed
            const Text(
              "Recently viewed products",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: size.height * 0.28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ProductCard("assets/images/new_arrival_1.png", "#WhipLash Mascara", "R 220.00",
                      extra: "SOLD OUT"),
                  _ProductCard("assets/images/new_Arrival_2.png",
                      "(H2) Oh-My - Serious Hydration", "R 349.00"),
                  _ProductCard(
                      "assets/images/offer1.png", "Wig Remover", "R 150.00"),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String img;
  final String title;
  final String price;
  final String? extra;

  const _ProductCard(this.img, this.title, this.price, {this.extra});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: size.width * 0.4,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  img,
                  width: double.infinity,
                  height: size.height * 0.18,
                  fit: BoxFit.cover,
                ),
              ),
              if (extra != null)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      extra!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
