import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/home_header.dart';
import '../../widgets/category_chips.dart';
import '../../data/static_data.dart';
import '../../widgets/black_footer.dart';
import '../../widgets/app_drawer.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _orderCtl = TextEditingController();
  final _contactCtl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoading = false;
  Map<String, dynamic>? _orderData;

  @override
  void dispose() {
    _orderCtl.dispose();
    _contactCtl.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    final orderId = _orderCtl.text.trim();
    final contact = _contactCtl.text.trim();

    // Validation
    if (orderId.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your Order Number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (contact.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your Email or Phone Number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _orderData = null;
    });

    try {
      final url = Uri.parse('https://beautyontapp.net/api/auth/customer/buy-it-again');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'order_id': orderId,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _orderData = data;
          _isLoading = false;
        });

        Get.snackbar(
          'Success',
          'Order found successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      } else if (response.statusCode == 404) {
        setState(() => _isLoading = false);
        
        Get.snackbar(
          'Order Not Found',
          'No order found with ID: $orderId',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() => _isLoading = false);
        
        Get.snackbar(
          'Authentication Error',
          'Please verify your email or phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() => _isLoading = false);
        
        Get.snackbar(
          'Error',
          'Failed to track order. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      print('API Error: $e');
      
      Get.snackbar(
        'Connection Error',
        'Unable to connect to server. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: Stack(
        children: [
          ListView(
            children: [
              // BLACK HEADER
              HomeHeader(
                onMenu: () => _scaffoldKey.currentState?.openDrawer(),
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
                    _Field(
                      hint: 'Order Number',
                      controller: _orderCtl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      hint: 'Email or Phone Number',
                      controller: _contactCtl,
                      keyboardType: TextInputType.emailAddress,
                    ),
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
                        onPressed: _isLoading ? null : _trackOrder,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: Image.asset(
                                  'assets/images/flow.gif',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Text(
                                'TRACK',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ORDER DETAILS (if found)
              if (_orderData != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: _OrderDetailsCard(orderData: _orderData!),
                ),

              const SizedBox(height: 28),

              // REUSABLE BLACK FOOTER
              const BlackFooter(),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child:  Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            'assets/images/flow.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tracking your order...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  
  const _Field({
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const _OrderDetailsCard({required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDEDED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Order Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            
            // Order ID
            _DetailRow(
              label: 'Order ID',
              value: orderData['order_id']?.toString() ?? 'N/A',
            ),
            
            // Status
            if (orderData['status'] != null)
              _DetailRow(
                label: 'Status',
                value: orderData['status'].toString(),
                valueColor: _getStatusColor(orderData['status'].toString()),
              ),
            
            // Date
            if (orderData['date'] != null || orderData['created_at'] != null)
              _DetailRow(
                label: 'Date',
                value: orderData['date']?.toString() ?? 
                       orderData['created_at']?.toString() ?? 
                       'N/A',
              ),
            
            // Total Amount
            if (orderData['total'] != null || orderData['amount'] != null)
              _DetailRow(
                label: 'Total',
                value: 'R ${orderData['total'] ?? orderData['amount']}',
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            
            // Products count
            if (orderData['products'] != null || orderData['items'] != null)
              _DetailRow(
                label: 'Items',
                value: '${(orderData['products'] ?? orderData['items']).length} products',
              ),
            
            const SizedBox(height: 16),
            
            // Buy Again Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.snackbar(
                    'Buy It Again',
                    'Adding items to cart...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  // TODO: Implement buy again functionality
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'BUY IT AGAIN',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            
            // View Details Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Order Details',
                    'Opening full order details...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  // TODO: Navigate to detailed order view
                },
                child: const Text(
                  'View Full Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('delivered') || statusLower.contains('complete')) {
      return Colors.green;
    } else if (statusLower.contains('pending') || statusLower.contains('processing')) {
      return Colors.orange;
    } else if (statusLower.contains('cancelled') || statusLower.contains('failed')) {
      return Colors.red;
    } else if (statusLower.contains('shipped') || statusLower.contains('transit')) {
      return Colors.blue;
    }
    return Colors.black;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}