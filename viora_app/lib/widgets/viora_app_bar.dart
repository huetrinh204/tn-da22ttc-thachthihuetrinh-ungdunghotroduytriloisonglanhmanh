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
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.primaryDarker, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : leading,
      automaticallyImplyLeading: false,
      title: showLogo
          ? Row(
              children: [
                Image.asset('assets/images/logo.png', height: 32),
                const SizedBox(width: 8),
                const Text(
                  'Viora',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarker,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          : title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarker,
                  ),
                )
              : null,
      actions: actions,
      bottom: bottom,
    );
  }
}
