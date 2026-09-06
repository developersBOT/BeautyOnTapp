import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  Future<void> _openSkinAnalysis() async {
    print('🔵 Starting Skin Analysis API call...');
    
    try {
      // Show loading
      Get.dialog(
        Center(
          child: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              'assets/images/flow.gif',
              fit: BoxFit.contain,
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final url = 'https://beautyontapp.net/api/make-services-webview';
      print('🔵 API URL: $url');

      final response = await http.get(Uri.parse(url));

      print('🔵 Response Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      // Close loading
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        print('🟢 API call successful');
        
        final data = json.decode(response.body);
        print('🟢 Decoded data: $data');

        if (data['success'] == true && data['url'] != null) {
          final webViewUrl = data['url'];
          print('🟢 Navigating to WebView with URL: $webViewUrl');
          
          Get.toNamed('/webview', arguments: {'url': webViewUrl});
          print('🟢 Navigation successful');
        } else {
          print('🔴 API returned invalid data');
          Get.snackbar(
            'Error',
            'Unable to load service',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
        }
      } else {
        print('🔴 API failed: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to connect. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('🔴 Exception: $e');
      print('🔴 Stack trace: $stackTrace');
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _openStoreSelector() {
    Get.bottomSheet(
      const ChangeStoreBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          children: [
            const SizedBox(height: 18),

            // Title row
            const Text(
              'Stores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 18),

            // Choose store button
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: w * 0.74,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _openStoreSelector,
                  child: const Text(
                    'Choose Your store',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Find a BeautyOnTApp
            InkWell(
              onTap: () {
                // TODO: open map / store finder
              },
              child: Row(
                children: const [
                  Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Find a BeautyOnTApp',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Book Skin Analysis
            InkWell(
              onTap: () {
                print('📱 Book Skin Analysis tapped');
                _openSkinAnalysis();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black12,
                    child: Image.asset("assets/images/Group.png"),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Skin Analysis',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Take the guesswork out of skincare & book appointment.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Store Model
class Store {
  final String name;
  final String address;
  final String timing;
  final bool isSelected;

  Store({
    required this.name,
    required this.address,
    required this.timing,
    this.isSelected = false,
  });
}

// Change Store Bottom Sheet
class ChangeStoreBottomSheet extends StatefulWidget {
  const ChangeStoreBottomSheet({super.key});

  @override
  State<ChangeStoreBottomSheet> createState() => _ChangeStoreBottomSheetState();
}

class _ChangeStoreBottomSheetState extends State<ChangeStoreBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 1; // FOURWAYS MALL selected by default

  final List<Store> stores = [
    Store(
      name: 'GATEWAY THEATRE OF SHOPPING',
      address: '1 Palm Blvd, Umhlanga Ridge, Durban, 4021, South Africa',
      timing: 'Open until 07:00 PM',
    ),
    Store(
      name: 'FOURWAYS MALL',
      address: '11 Ruby Cl, Witkoppen, Sandton, 2068',
      timing: '',
      isSelected: true,
    ),
    Store(
      name: 'MALL OF AFRICA',
      address: 'Magwa Cres, Waterval 5-Ir, Midrand, 1686, South Africa',
      timing: 'Open until 08:30 PM',
    ),
    Store(
      name: 'MENLYN PARK',
      address: 'Garsfon AH, Pretoria, 0063, South Africa',
      timing: 'Open until 08:00 PM',
    ),
    Store(
      name: 'SANDTON CITY',
      address: '83 Rivonia Rd, Sandhurst, Sandton, 2196',
      timing: '',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Store',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'City & State or ZIP',
                hintStyle: const TextStyle(
                  color: Colors.black38,
                  fontSize: 14,
                ),
                suffixIcon: const Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Store list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Radio button
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected ? Colors.blue : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Store details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      store.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: View store details
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'View details',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                store.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                              if (store.timing.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  store.timing,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Choose button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  // Save selected store and close
                  final selectedStore = stores[selectedIndex];
                  print('Selected store: ${selectedStore.name}');
                  Get.back();
                  
                  Get.snackbar(
                    'Store Selected',
                    selectedStore.name,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Text(
                  'Choose This Store',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}