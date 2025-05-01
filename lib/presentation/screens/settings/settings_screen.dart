import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/language_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.translate('settings'),
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('language'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Text(
                      localizations.translate('change_language'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const LanguageSwitcher(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('theme'),
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.brightness_4,
                title: localizations.translate('dark_mode'),
                trailing: Switch(
                  value: false, // Replace with actual theme state
                  onChanged: (value) {
                    // Implement theme change
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  // Implement theme change
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('about'),
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.info,
                title: localizations.translate('app_name'),
                subtitle: 'v1.0.0',
                onTap: () {
                  // Show about dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
