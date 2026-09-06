import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'store_webview.dart';

// Splash timing (smart splash, approved 5 Jul 2026):
// 3.0s logo rotation, then a hold of UP TO 1.2s that is skipped the moment
// the store has finished preloading, then a 0.8s fade-out with a zoom-through
// effect that reveals the store already rendered underneath. Worst case
// matches the original 5.0s spec; typical launch hands over at ~3.8s.
const Duration kRotationDuration = Duration(seconds: 3);
const Duration kHoldDuration = Duration(milliseconds: 1200);
const Duration kFadeOutDuration = Duration(milliseconds: 800);

/// Opaque black splash overlay. Rendered ON TOP of the store WebView (see
/// AppRoot in main.dart); calls [onFinished] when its exit animation ends.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationCtl;
  late final Animation<double> _turns;
  late final AnimationController _fadeCtl;
  late final Animation<double> _opacity;
  late final Animation<double> _zoom;

  @override
  void initState() {
    super.initState();

    _rotationCtl = AnimationController(
      vsync: this,
      duration: kRotationDuration,
    );
    _turns = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _rotationCtl, curve: Curves.easeInOutCubic),
    );

    _fadeCtl = AnimationController(
      vsync: this,
      duration: kFadeOutDuration,
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeCtl, curve: Curves.easeOut),
    );
    // Slight scale-up while fading = zoom-through into the store beneath.
    _zoom = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _fadeCtl, curve: Curves.easeOutCubic),
    );

    _run();
  }

  Future<void> _run() async {
    await _rotationCtl.forward();
    await _holdUntilStoreReady();
    if (!mounted) return;
    await _fadeCtl.forward();
    if (!mounted) return;
    widget.onFinished();
  }

  /// Smart splash: waits at most [kHoldDuration], but returns immediately
  /// (or as soon as it happens) once the store's first page has rendered.
  Future<void> _holdUntilStoreReady() async {
    if (StoreWebView.isStoreReady) return;
    final completer = Completer<void>();
    void onReady() {
      if (StoreWebView.isStoreReady && !completer.isCompleted) {
        completer.complete();
      }
    }

    StoreWebView.storeReadyListenable.addListener(onReady);
    try {
      await Future.any(<Future<void>>[
        completer.future,
        Future.delayed(kHoldDuration),
      ]);
    } finally {
      StoreWebView.storeReadyListenable.removeListener(onReady);
    }
  }

  @override
  void dispose() {
    _rotationCtl.dispose();
    _fadeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double logoW = size.width * 0.75;
    final double logoH = logoW * (175.0 / 310.0);

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _zoom,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: logoW,
                  height: logoH,
                  child: RotationTransition(
                    turns: _turns,
                    child: SvgPicture.asset(
                      'assets/images/u_logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const AnimatedTagline(),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// ANIMATED TEXT + IMAGE (Typing Effect + Fade-in Image)
// =======================================================

class AnimatedTagline extends StatefulWidget {
  const AnimatedTagline({super.key});

  @override
  State<AnimatedTagline> createState() => _AnimatedTaglineState();
}

class _AnimatedTaglineState extends State<AnimatedTagline> {
  String text = "BEAUTY THAT CARES";
  int charIndex = 0;
  bool showImage = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Typing animation
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      setState(() {
        charIndex++;
      });
    }

    // Fade-in image after text finishes
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      showImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text.substring(0, charIndex),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 5),
        AnimatedOpacity(
          opacity: showImage ? 1 : 0,
          duration: const Duration(milliseconds: 600),
          child: SvgPicture.asset(
            "assets/images/Vector.svg",
            height: 18,
          ),
        ),
      ],
    );
  }
}
