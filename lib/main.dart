import 'package:beautyontapp/Brand/logo_detail_explain.dart';
import 'package:beautyontapp/Brand/logo_explain.dart';
import 'package:beautyontapp/Screens/SkinAnalysisDetailScreen.dart';
import 'package:beautyontapp/Screens/Upper%20List/bath_and_body_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/beauty_under_200.dart';
import 'package:beautyontapp/Screens/Upper%20List/book_skin_analysis_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/brand_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/hair_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/korean_skin_care_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/make_up_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/men_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/mini_size_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/sale_and_offer_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/skin_care_screen.dart';
import 'package:beautyontapp/Screens/Upper%20List/sun_care_screen.dart';
import 'package:beautyontapp/product_list_screen_updated.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautyontapp/splash_screen.dart';
import 'package:beautyontapp/Auth_Screens/login_screen.dart';
import 'package:beautyontapp/Auth_Screens/signup_screen.dart';
import 'package:beautyontapp/home_shell.dart';
import 'package:beautyontapp/Screens/cart_screen.dart';
import 'package:beautyontapp/Screens/track_order_screen.dart';
import 'package:beautyontapp/Screens/catalog_screen.dart';
import 'package:beautyontapp/Screens/loves_screen.dart';
import 'package:beautyontapp/Screens/product_detail_screen.dart';
import 'package:beautyontapp/Screens/reset_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beauty On Tapp',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),

      // Simple named routes with GetX
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/home', page: () => const HomeShell()),
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/track-order', page: () => const TrackOrderScreen()),
        GetPage(name: '/catalog', page: () => const CatalogScreen()),
        GetPage(name: '/loves', page: () => const LovesScreen()),
        GetPage(name: '/product', page: () => const ProductDetailScreen()),
        GetPage(name: '/reset-password', page: () => const ResetPasswordScreen()),
        GetPage(name: '/brands', page: () => BrandsScreen()),
        GetPage(name: '/skin-care', page: () => SkinCareScreen()),
        GetPage(name: '/hair', page: () => const HairScreen()),
        GetPage(name: '/make-up', page: () => const MakeUpScreen()),
        GetPage(name: '/men', page: () => const MenScreen()),
        GetPage(name: '/bath-body', page: () => const BathAndBodyScreen()),
        GetPage(name: '/korean-skin-care', page: () => const KoreanSkinCareScreen()),
        GetPage(name: '/suncare', page: () => const SunCareScreen()),
        GetPage(name: '/sale-offer', page: () => const SaleAndOfferScreen()),
        GetPage(name: '/book-skin-analysis', page: () => const BookSkinAnalysisScreen()),
        GetPage(name: '/skin-analysis-detail', page: () => const SkinAnalysisDetailScreen()),
        GetPage(name: '/beauty-under-200', page: () => const BeautyUnder200Screen()),
        GetPage(name: '/mini-size', page: () => const MiniSizeScreen()),

        // ✅ New route for brand detail
        GetPage(name: '/logo-explain', page: () => const LogoExplainScreen()),
        GetPage(name: '/logo-detail-explain', page: () => const LogoDetailExplain()),
        GetPage(name: '/products', page: () => const ProductListScreenUpdated()),

      ],
    );
  }
}
