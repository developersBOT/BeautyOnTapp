// lib/Screens/korean_skin_care_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For koreanSkinCareEntries

class KoreanSkinCareScreen extends StatelessWidget {
  const KoreanSkinCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    // Group koreanSkinCareEntries by first letter
    Map<String, List<String>> koreanByLetter = {};
    for (var entry in koreanSkinCareEntries) {
      if (entry.isNotEmpty) {
        String firstLetter = entry[0].toLowerCase();
        koreanByLetter.putIfAbsent(firstLetter, () => []).add(entry);
      }
    }

    // Sort the entries within each letter group
    koreanByLetter.forEach((key, value) {
      value.sort();
    });

    List<String> letters = koreanByLetter.keys.toList()..sort();
    List<Widget> sections = [];

    for (var l in letters) {
      final letter = l.toUpperCase();
      final items = koreanByLetter[l] ?? [];

      sections.add(
        Padding(
          padding: EdgeInsets.only(left: w * 0.04, top: 16, bottom: 8),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      sections.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Wrap(
            spacing: w * 0.05,
            runSpacing: 8,
            children: items.map((item) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/products',
                    arguments: {
                      'title': item,  // Use the item as title
                      'keyword': item,  // Use the item as keyword for API call
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Korean SkinCare',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: sections,
      ),
    );
  }
}