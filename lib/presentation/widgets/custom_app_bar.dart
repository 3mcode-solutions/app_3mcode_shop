import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.isRtl;

    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? AppColors.primary,
      elevation: elevation,
      leading:
          showBackButton
              ? leading ??
                  IconButton(
                    icon: Icon(
                      isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
              : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
