import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For makeUpEntries

class MakeUpScreen extends StatelessWidget {
  const MakeUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    // Group makeUpEntries by first letter
    Map<String, List<String>> makeUpByLetter = {};
    for (var entry in makeUpEntries) {
      if (entry.isNotEmpty) {
        String firstLetter = entry[0].toLowerCase();
        makeUpByLetter.putIfAbsent(firstLetter, () => []).add(entry);
      }
    }

    // Sort the entries within each letter group
    makeUpByLetter.forEach((key, value) {
      value.sort();
    });

    List<String> letters = makeUpByLetter.keys.toList()..sort();
    List<Widget> sections = [];

    for (var l in letters) {
      final letter = l.toUpperCase();
      final items = makeUpByLetter[l] ?? [];

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
                      'title': item,
                      'keyword': item, // Pass category keyword for product search
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
          'Make Up',
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