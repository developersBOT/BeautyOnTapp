import 'package:beautyontapp/Screens/BottomNavBarScreen/exclusive_screen.dart';
import 'package:beautyontapp/Screens/BottomNavBarScreen/home_screen.dart';
import 'package:beautyontapp/Screens/BottomNavBarScreen/me_screen.dart';
import 'package:beautyontapp/Screens/BottomNavBarScreen/shop_screen.dart';
import 'package:beautyontapp/Screens/BottomNavBarScreen/stores_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(), 
    ShopScreen(),    // index 1
    ExclusiveScreen(),                   // index 2
    MeScreen(),   // index 3
    StoresScreen(),     // index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
