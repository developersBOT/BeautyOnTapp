import 'package:flutter/material.dart';
import 'footer_stats_row.dart';
import 'footer_links.dart';

class FooterSection extends StatelessWidget {
  final List<Map<String, String>> stats;
  final Map<String, List<String>> links;
  final String email;
  final String address;

  const FooterSection({
    super.key,
    required this.stats,
    required this.links,
    required this.email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(bottom: 18, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FooterStatsRow(items: stats),
          Divider(color: Colors.white24, thickness: 1, indent: w * 0.04, endIndent: w * 0.04),
          FooterLinks(sections: links),
          Divider(color: Colors.white24, thickness: 1, indent: w * 0.04, endIndent: w * 0.04),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 12),
            child: Column(
              children: [
                const Text('Contact Us', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(address, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                const Text('© 2025 BeautyOnTApp', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
