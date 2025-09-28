import 'dart:async';
import 'package:beautyontapp/Helper/session_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _turns;

  @override
  void initState() {
    super.initState();

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _turns = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeInOutCubic),
    );

    _ctl.forward();
    _ctl.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 200));

        // 🔑 Check if logged in
        final loggedIn = await SessionHelper.isLoggedIn();
        if (loggedIn) {
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double logoW = size.width * 0.75;
    final double logoH = logoW * (175.0 / 310.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: logoW,
          height: logoH,
          child: RotationTransition(
            turns: _turns,
            child: SvgPicture.asset(
              'assets/images/app_logo_icon.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
