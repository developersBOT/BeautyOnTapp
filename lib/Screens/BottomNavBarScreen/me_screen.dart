import 'dart:convert';
import 'package:beautyontapp/Auth_Screens/login_screen.dart';
import 'package:beautyontapp/Screens/track_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch user data from API
Future<Map<String, dynamic>> fetchUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken == null) {
    throw Exception('User is not authenticated');
  }

  final response = await http.get(
    Uri.parse('https://beautyontapp.net/api/auth/profile'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch user data');
  }
}

// Function to logout by calling the API
Future<void> logout(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('https://beautyontapp.net/api/auth/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('access_token');
      Get.offAllNamed('/login');
      Get.snackbar('Logged out', 'You have been logged out successfully',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      throw Exception('Failed to logout');
    }
  } catch (e) {
    Get.snackbar('Error', 'An error occurred during logout: $e',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  /// Common menu section (shown in both states)
  Widget _buildMenuSection() {
    return Column(
      children: [
        const Divider(height: 28, color: Color(0xFFEDEDED)),
        _MenuTile(
          icon: Icons.refresh_outlined,
          title: 'Buy It Again',
          subtitle: 'Reorder from in-store and online purchases',
          onTap: () {
            Get.to(()=> LoginScreen());
          },
        ),
        const Divider(height: 1, color: Color(0xFFEDEDED)),
        _MenuTile(
          icon: Icons.inventory_2_outlined,
          title: 'Orders',
          subtitle: 'View & track online or pickup orders',
          onTap: () => Get.toNamed('/track-order'),
        ),
        const Divider(height: 1, color: Color(0xFFEDEDED)),
        _MenuTile(
          icon: Icons.favorite_border,
          title: 'Loves',
          subtitle: 'View saved products',
          onTap: () => Get.toNamed('/loves'),
        ),
        const Divider(height: 1, color: Color(0xFFEDEDED)),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;
    final greeting = _getTimeOfDayGreeting();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            // Treat errors or null as "not logged in"
            final bool isLoggedIn =
                snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                !snapshot.hasError;

            final userData = snapshot.data;
            final firstName =
                isLoggedIn ? (userData?['customer']?['firstName'] ?? 'User') : 'Bestiee🌙';
            final lastName =
                isLoggedIn ? (userData?['customer']?['lastName'] ?? '') : '';
            final fullName = ('$firstName $lastName').trim();

            // Optional: show loader only while first load happens
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/images/flow.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: pad),
              children: [
                const SizedBox(height: 10),
                // Header
                Row(
                  children: [
                    const Text(
                      'Community',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) Get.back();
                      },
                    ),
                  ],
                ),
                // Greeting row (same design for both)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black12,
                      child: Image.asset("assets/images/Group.png"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$greeting $fullName.',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    // Show Logout only if logged in
                    if (isLoggedIn)
                      TextButton(
                        onPressed: () => _showLogoutDialog(context),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // If NOT logged in, show Login/Create buttons ABOVE the rest
                if (!isLoggedIn) ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () => Get.toNamed('/login'),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () => Get.toNamed('/signup'),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Menu Section (same for both)
                _buildMenuSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black87,
                        height: 1.25,
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
  }
}