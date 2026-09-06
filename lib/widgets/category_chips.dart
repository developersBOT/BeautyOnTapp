import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final void Function(String)? onTap;
  final EdgeInsets margin;

  const CategoryChips({
    super.key,
    required this.categories,
    this.onTap,
    this.margin = const EdgeInsets.only(top: 10),
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Container(
      margin: margin,
      height: 42,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onTap?.call(categories[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15), // thoda strong
                    blurRadius: 8,  // soft edge
                    spreadRadius: 1, // halka spread all sides
                    offset: const Offset(0, 0), // center me shadow
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}
