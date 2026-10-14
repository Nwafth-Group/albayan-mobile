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
  /// Index of the Cart tab within [_navItems] — kept in sync with the list
  /// above so [cartBadgeCount] is drawn on the right chip.
  static const int cartTabIndex = 3;

  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Number of items in the cart, shown as a small badge over the Cart
  /// tab's icon. 0 (or less) hides the badge.
  final int cartBadgeCount;

  const MainBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
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
                badgeCount: i == cartTabIndex ? cartBadgeCount : 0,
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
  final int badgeCount;

  const _NavChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        height: 48,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 18)
            : const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _icon(color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    item.labelKey.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
    final icon = Image.asset(
      item.icon,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) =>
          Icon(item.fallbackIcon, color: color, size: size),
    );
    if (badgeCount <= 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          end: -8,
          top: -6,
          child: _CountBadge(count: badgeCount),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
