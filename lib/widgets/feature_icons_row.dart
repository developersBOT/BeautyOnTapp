import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeatureIconsRow extends StatelessWidget {
  final List<Map<String, String>> items;
  const FeatureIconsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((e) {
          return SizedBox(
            width: (w - w * 0.16) / items.length - 8,
            child: Column(
              children: [
                const Icon(CupertinoIcons.checkmark_seal, size: 28),
                const SizedBox(height: 8),
                Text(e['title']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(e['subtitle']!, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
