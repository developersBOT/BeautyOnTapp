import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final String hint;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onSubmit,
    this.hint = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.paddingOf(context).top;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(12, padTop + 8, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE6E6E6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => onSubmit(),
                    ),
                  ),
                  IconButton(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.search, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
