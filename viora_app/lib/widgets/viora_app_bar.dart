import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AppBar chuẩn dùng chung — hiển thị logo Viora ở title
class VioraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const VioraAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.actions,
    this.leading,
    this.showBack = false,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? const Color(0xFF81C784) : AppColors.primaryDarker;
    final iconColor = isDark ? const Color(0xFF81C784) : AppColors.primaryDark;

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : leading,
      automaticallyImplyLeading: false,
      title: showLogo
          ? Row(
              children: [
                Image.asset('assets/images/logo.png', height: 32),
                const SizedBox(width: 8),
                Text(
                  'Viora',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          : title != null
              ? Text(title!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor))
              : null,
      actions: actions,
      bottom: bottom,
    );
  }
}
