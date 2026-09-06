import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final VoidCallback onCart;

  const HomeHeader({
    super.key,
    required this.onMenu,
    required this.onSearch,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.paddingOf(context).top;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        top: padTop + 8,
        left: 8,
        right: 8,
        bottom: 10,
      ),
      child: SizedBox(
        height: 44, // header row height
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ---- CENTER LOGO (always centered) ----
            Center(
              child: SizedBox(
                height: 27.11,
                child: Image.asset(
                  'assets/images/logo_icon.png',
                  fit: BoxFit.contain,
                  color: Colors.white, // if your asset is monochrome
                ),
              ),
            ),

            // ---- SIDE ACTIONS (left & right) ----
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: Colors.white,
                    ),
                    splashRadius: 22,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onSearch,
                        icon: const Icon(CupertinoIcons.search, color: Colors.white),
                        splashRadius: 22,
                      ),
                      IconButton(
                        onPressed: onCart,
                        icon: const Icon(CupertinoIcons.bag, color: Colors.white),
                        splashRadius: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
