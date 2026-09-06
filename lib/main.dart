import 'package:beautyontapp/splash_screen.dart';
import 'package:beautyontapp/store_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The store WebView controller is created up front; the page itself starts
  // loading right after the FIRST frame (under the splash), once the platform
  // view has real bounds — loading into a zero-sized WKWebView permanently
  // breaks the page's layout viewport. See StoreWebView._scheduleInitialLoad.
  StoreWebView.preload();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeautyOnTApp',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      home: const AppRoot(),
    );
  }
}

/// Hosts the store WebView from the very FIRST frame with the splash laid
/// on top of it. The WebView is never detached/re-attached, so the page
/// renders behind the splash and is already painted when the splash fades —
/// this is what prevents any white flash at handover.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Edge-to-edge: content draws behind the system bars on both platforms.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Light status-bar icons over the black splash.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onSplashFinished() {
    // Dark icons over the white store once the splash is gone.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    setState(() => _splashDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const StoreWebView(),
        if (!_splashDone) SplashScreen(onFinished: _onSplashFinished),
      ],
    );
  }
}
