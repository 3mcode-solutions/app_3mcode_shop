import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/constants/assets_paths.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/user_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_state.dart';
import 'package:app_3mcode_shop/presentation/screens/account/about_app_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/account/profile_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/login_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';
import 'package:app_3mcode_shop/presentation/widgets/language_switcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('account')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context, localizations),
            const SizedBox(height: 24),
            _buildSettingsSection(context, localizations),
            const SizedBox(height: 16),
            _buildPreferencesSection(context, localizations),
            const SizedBox(height: 16),
            _buildSupportSection(context, localizations),
            const SizedBox(height: 32),
            _buildSignOutButton(context, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;
        final user = isAuthenticated ? (state as Authenticated).user : null;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      isAuthenticated && user != null && user.photoUrl != null
                          ? _getProfileImage(user.photoUrl!)
                          : null,
                  child:
                      (isAuthenticated && user != null && user.photoUrl != null)
                          ? null
                          : Icon(
                            Icons.person,
                            size: 40,
                            color:
                                isAuthenticated
                                    ? AppColors.primary
                                    : Colors.grey,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuthenticated
                            ? user!.name
                            : localizations.translate('guest_user'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAuthenticated
                            ? user!.email
                            : localizations.translate('guest_user_message'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      if (isAuthenticated)
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProfileScreen(user: user!),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(localizations.translate('edit_profile')),
                        )
                      else
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(localizations.translate('sign_in')),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildSectionHeader(
            localizations.translate('settings'),
            Icons.settings,
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.language,
            title: localizations.translate('language'),
            trailing: const LanguageSwitcher(),
          ),
          const Divider(height: 1),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              bool isDarkMode = false;

              if (state is ThemeLoaded) {
                isDarkMode = state.isDarkMode;
              }

              return _buildSettingsItem(
                context: context,
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: localizations.translate('dark_mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(const ToggleTheme());

                    AnimatedToast.show(
                      context: context,
                      message:
                          value
                              ? localizations.translate('dark_mode_enabled')
                              : localizations.translate('light_mode_enabled'),
                      type: ToastType.success,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.notifications,
            title: localizations.translate('notifications'),
            trailing: Switch(
              value: false, // In a real app, this would be a stored preference
              onChanged: (value) {
                // In a real app, this would update the notification preference
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? localizations.translate('notifications_enabled')
                          : localizations.translate('notifications_disabled'),
                    ),
                  ),
                );
              },
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildSectionHeader(
            localizations.translate('preferences'),
            Icons.tune,
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.location_on,
            title: localizations.translate('shipping_addresses'),
            onTap: () {
              // In a real app, this would navigate to the addresses screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.credit_card,
            title: localizations.translate('payment_methods'),
            onTap: () {
              // In a real app, this would navigate to the payment methods screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.currency_exchange,
            title: localizations.translate('currency'),
            subtitle:
                'USD (\$)', // In a real app, this would be the selected currency
            onTap: () {
              // In a real app, this would navigate to the currency selection screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildSectionHeader(localizations.translate('support'), Icons.help),
          _buildSettingsItem(
            context: context,
            icon: Icons.info,
            title: localizations.translate('about_app'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.help_center,
            title: localizations.translate('help_center'),
            onTap: () {
              // In a real app, this would navigate to the help center screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.privacy_tip,
            title: localizations.translate('privacy_policy'),
            onTap: () {
              // In a real app, this would navigate to the privacy policy screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            context: context,
            icon: Icons.description,
            title: localizations.translate('terms_of_service'),
            onTap: () {
              // In a real app, this would navigate to the terms of service screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('feature_coming_soon')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;

        if (!isAuthenticated) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(
                        localizations.translate('sign_out_confirmation_title'),
                      ),
                      content: Text(
                        localizations.translate(
                          'sign_out_confirmation_message',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations.translate('cancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthBloc>().add(const LogoutUser());

                            AnimatedToast.show(
                              context: context,
                              message: localizations.translate(
                                'signed_out_successfully',
                              ),
                              type: ToastType.success,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(localizations.translate('sign_out')),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.logout),
            label: Text(localizations.translate('sign_out')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  ImageProvider _getProfileImage(String photoUrl) {
    if (photoUrl.startsWith('/')) {
      return FileImage(File(photoUrl));
    } else {
      return NetworkImage(photoUrl);
    }
  }
}
