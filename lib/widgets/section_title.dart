import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onShowMore;

  const SectionTitle({super.key, required this.title, this.onShowMore});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (onShowMore != null)
            TextButton(
              onPressed: onShowMore,
              child: const Text('Show More', style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}
