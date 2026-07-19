import 'package:beautyontapp/Screens/SkinAnalysisDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookSkinAnalysisScreen extends StatelessWidget {
  const BookSkinAnalysisScreen({super.key});

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
        title: const Text(
          "Services & Events",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            const Text(
              "Elevate your skincare journey with our in-store skin analysis "
              "where advanced diagnostic technology meets personalized care. "
              "By examining your skin’s unique characteristics, from hydration "
              "levels to texture and tone, we curate product recommendations "
              "designed to deliver visible, lasting results. It’s a smarter, "
              "more cost effective & luxurious way to discover what truly works "
              "for your skin.",
              style: TextStyle(
                fontSize: 14.5,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Service image + details
            InkWell(
              onTap: () {
                Get.to(() => const SkinAnalysisDetailScreen());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/book1.png",
                    width: size.width * 0.25,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Skin Analysis",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Your Skin, Scientifically Understood",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "R 220.00",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // What to Expect
            const Text(
              "What to Expect at the Beauty Studio",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Here’s what you need to know before your Skin Analysis Service.",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Expectation items (3 total, scrollable vertically)
            _InfoTile(
              icon: "assets/images/book2.png", // replace with your asset
              title: "Arrival",
              desc:
                  "Please arrive with makeup-free skin. Change of plans? If you need "
                  "to cancel or reschedule, please do so at least 24 hours in advance.",
            ),
            const Divider(height: 32, color: Color(0xFFEDEDED)),

            _InfoTile(
              icon: "assets/images/book3.png", // replace with your asset
              title: "Waiver",
              desc:
                  "Upon check-in, you'll be asked to review the Consent of Rights and "
                  "Assumption of Risk form. A guardian must be present to sign the waiver.",
            ),
            const Divider(height: 32, color: Color(0xFFEDEDED)),

            _InfoTile(
              icon: "assets/images/book4.png", // replace with your asset
              title: "Consultation",
              desc:
                  "After your analysis, our beauty expert will walk you through the results "
                  "and recommend the best personalized skincare products for you.",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          icon,
          width: size.width * 0.13,
          height: size.width * 0.13,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
