// ============================================
// FILE: lib/widgets/main_bottom_nav_bar.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class _NavItemData {
  final String icon;
  final IconData fallbackIcon;
  final String labelKey;
  const _NavItemData({
    required this.icon,
    required this.fallbackIcon,
    required this.labelKey,
  });
}

final List<_NavItemData> _navItems = [
  _NavItemData(
    icon: AppImages.home,
    fallbackIcon: Icons.home_outlined,
    labelKey: AppStrings.navHome,
  ),
  const _NavItemData(
    icon: AppImages.library,
    fallbackIcon: Icons.menu_book_outlined,
    labelKey: AppStrings.navLibrary,
  ),
  const _NavItemData(
    icon: AppImages.search2,
    fallbackIcon: Icons.search_rounded,
    labelKey: AppStrings.navSearch,
  ),
  const _NavItemData(
    icon: AppImages.cart,
    fallbackIcon: Icons.shopping_cart_outlined,
    labelKey: AppStrings.navCart,
  ),
  const _NavItemData(
    icon: AppImages.setting,
    fallbackIcon: Icons.settings_outlined,
    labelKey: AppStrings.navSettings,
  ),
];

class MainBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navItems.length, (i) {
              final isSelected = i == selectedIndex;
              final chip = _NavChip(
                item: _navItems[i],
                isSelected: isSelected,
                onTap: () => onTap(i),
              );
              return isSelected ? Expanded(child: chip) : chip;
            }),
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        height: 56,
        width: isSelected ? null : 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(isSelected ? 26 : 28),
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _icon(color: Colors.white, size: 20),
                  const SizedBox(height: 3),
                  Text(
                    item.labelKey.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : _icon(color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _icon({required Color color, required double size}) {
    return Image.asset(
      item.icon,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) =>
          Icon(item.fallbackIcon, color: color, size: size),
    );
  }
}
