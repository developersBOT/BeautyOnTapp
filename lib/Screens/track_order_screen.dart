import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/home_header.dart';
import '../../widgets/category_chips.dart';
import '../../data/static_data.dart';
import '../../widgets/black_footer.dart';
import '../../widgets/app_drawer.dart'; // <-- drawer

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _orderCtl = TextEditingController();
  final _contactCtl = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>(); // <-- use this

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;

    return Scaffold(
      key: _scaffoldKey, // <-- attach key
      backgroundColor: Colors.white,
      // add drawer so menu button safely opens it
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),

      body: ListView(
        children: [
          // BLACK HEADER
          HomeHeader(
            onMenu: () => _scaffoldKey.currentState?.openDrawer(), // <-- safe
            onSearch: () => Get.snackbar('Search', 'Open search'),
            onCart: () => Get.toNamed('/cart'),
          ),

          // FILTER CHIPS
          CategoryChips(
            categories: topCategories,
            margin: const EdgeInsets.only(top: 10),
          ),
          const SizedBox(height: 16),

          // TITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: const Text(
              'Track Your Order',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),

          // FORM
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              children: [
                _Field(hint: 'Order Number', controller: _orderCtl),
                const SizedBox(height: 12),
                _Field(hint: 'Email or Phone Number', controller: _contactCtl),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Get.snackbar('Track', 'Looking up order…',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Text(
                      'TRACK',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // REUSABLE BLACK FOOTER
          const BlackFooter(),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const _Field({required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
    );
  }
}
