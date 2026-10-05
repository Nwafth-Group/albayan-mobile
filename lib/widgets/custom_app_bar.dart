import 'package:albayan/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String title;
  final Color color;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final List<Widget> actions;

  const CustomAppBar({
    Key? key,
    this.showBack = true,
    this.title = "",
    this.color = AppColors.primary,
    this.titleFontSize = 16,
    this.titleFontWeight = FontWeight.bold,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: color),
          onPressed: () => AppNavigator.pop(),
        ),
        title: title.isNotEmpty?Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: titleFontWeight,
            color: color,
          ),
        ):null, actions: actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
