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

class _HomeShellState extends State<HomeShell>
    with AutomaticKeepAliveClientMixin {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    ShopScreen(),
    ExclusiveScreen(),
    MeScreen(),
    StoresScreen(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // ✅ Workaround for Flutter 3.24 BottomNavigationBar bug
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) {
          if (mounted) setState(() => _index = i);
        },
      ),
    );
  }
}
