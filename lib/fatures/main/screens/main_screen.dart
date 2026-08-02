// ============================================
// FILE: lib/fatures/main/screens/main_screen.dart
// ============================================

import 'package:albayan/fatures/cart/screens/cart_screen.dart';
import 'package:albayan/fatures/home/screens/home_screen.dart';
import 'package:albayan/fatures/library/screens/library_screen.dart';
import 'package:albayan/fatures/search/screens/search_screen.dart';
import 'package:albayan/fatures/settings/screens/settings_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(),
    SearchScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
