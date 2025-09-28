import 'package:flutter/material.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          children: [
            const SizedBox(height: 18),

            // Title row (NO cross icon, NO divider)
            const Text(
              'Stores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 18),

            // Choose store (centered pill button)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: w * 0.74,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    // TODO: open store selector
                  },
                  child: const Text(
                    'Choose Your store',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Find a BeautyOnTApp (link-ish row)
            InkWell(
              onTap: () {
                // TODO: open map / store finder
              },
              child: Row(
                children: const [
                  Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Find a BeautyOnTApp',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Book Skin Analysis
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black12,
                  child: Image.asset("assets/images/Group.png"),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Skin Analysis',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Take the guesswork out of skincare & book appointment.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
