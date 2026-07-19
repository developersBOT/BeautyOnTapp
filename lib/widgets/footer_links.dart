import 'package:flutter/material.dart';

class FooterLinks extends StatelessWidget {
  final Map<String, List<String>> sections;
  const FooterLinks({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.key,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: e.value
                      .map((x) => Text(x,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)))
                      .toList(),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
