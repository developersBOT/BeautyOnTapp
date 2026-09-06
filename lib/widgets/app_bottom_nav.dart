import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavItem {
  final String label;
  final String icon;       // outline/regular state
  final String activeIcon; // selected state
  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Change these asset paths to your own SVGs
const List<NavItem> defaultNavItems = [
  NavItem(  
    label: 'Home',
    icon: 'assets/images/home.svg',
    activeIcon: 'assets/icons/home.svg',
  ),
  NavItem(
    label: 'Shop',
    icon: 'assets/images/shop.svg',
    activeIcon: 'assets/icons/bag.svg',
  ),
  NavItem(
    label: 'Exclusive',
    icon: 'assets/images/exclusive.svg',
    activeIcon: 'assets/icons/gift.svg',
  ),
  NavItem(
    label: 'Me',
    icon: 'assets/images/me.svg',
    activeIcon: 'assets/icons/heart.svg',
  ),
  NavItem(
    label: 'Stores',
    icon: 'assets/images/stores.svg',
    activeIcon: 'assets/icons/store.svg',
  ),
];

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultNavItems,
  });

  @override
  Widget build(BuildContext context) {
    const unselectedColor = Colors.black54;
    const selectedColor = Colors.black;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      showUnselectedLabels: true,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selectedColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: unselectedColor,
      ),
      selectedIconTheme: const IconThemeData(size: 24, color: selectedColor),
      unselectedIconTheme: const IconThemeData(size: 24, color: unselectedColor),
      items: items
          .map(
            (it) => BottomNavigationBarItem(
              icon: _SvgIcon(asset: it.icon, color: unselectedColor),
              activeIcon: _SvgIcon(asset: it.activeIcon, color: selectedColor),
              label: it.label,
            ),
          )
          .toList(),
    );
  }
}

class _SvgIcon extends StatelessWidget {
  final String asset;
  final Color color;
  const _SvgIcon({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      // This recolors the SVG (works if your SVG uses fills/strokes, not images)
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // Avoid layout jumps in M3
      fit: BoxFit.contain,
    );
  }
}
