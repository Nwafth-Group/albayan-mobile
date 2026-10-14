// ============================================
// FILE: lib/fatures/main/screens/main_screen.dart
// ============================================

import 'dart:async';

import 'package:albayan/fatures/cart/data/datasource/cart_remote_data_source.dart';
import 'package:albayan/fatures/cart/screens/cart_screen.dart';
import 'package:albayan/fatures/cart/utils/cart_events.dart';
import 'package:albayan/fatures/home/screens/home_screen.dart';
import 'package:albayan/fatures/library/screens/library_screen.dart';
import 'package:albayan/fatures/search/screens/search_screen.dart';
import 'package:albayan/fatures/settings/screens/settings_screen.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/widgets/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final CartRemoteDataSource _cartDataSource =
      CartRemoteDataSourceImpl(ApiService());
  int _cartItemCount = 0;
  StreamSubscription<void>? _cartChangesSub;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadCartCount();
    _cartChangesSub = CartEvents.changes.listen((_) => _loadCartCount());
  }

  @override
  void dispose() {
    _cartChangesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartDataSource.getCart();
      if (!mounted) return;
      setState(() => _cartItemCount = cart.itemsCount);
    } catch (_) {
      // Badge just stays at its last known count on failure.
    }
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const SearchScreen(),
    const CartScreen(),
    // The Settings tab's back arrow returns to Home.
    SettingsScreen(onBack: () => _onTabTapped(0)),
  ];

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
        cartBadgeCount: _cartItemCount,
      ),
    );
  }
}
