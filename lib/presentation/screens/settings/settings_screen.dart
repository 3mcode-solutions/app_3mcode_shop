import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_state.dart';
import 'package:app_3mcode_shop/presentation/screens/account/about_app_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/account/profile_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/login_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/woo_products_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';
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
          // اللغة
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

          // السمة
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('theme'),
            children: [
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
                                  : localizations.translate(
                                    'light_mode_enabled',
                                  ),
                          type: ToastType.success,
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {
                      context.read<ThemeBloc>().add(const ToggleTheme());

                      final newState = context.read<ThemeBloc>().state;
                      final willBeDarkMode =
                          newState is ThemeLoaded ? !newState.isDarkMode : true;

                      AnimatedToast.show(
                        context: context,
                        message:
                            willBeDarkMode
                                ? localizations.translate('dark_mode_enabled')
                                : localizations.translate('light_mode_enabled'),
                        type: ToastType.success,
                      );
                    },
                  );
                },
              ),

              // خيار اتباع إعدادات النظام
              _buildSettingsItem(
                context: context,
                icon: Icons.settings_system_daydream,
                title:
                    localizations.translate('follow_system') ??
                    'Follow System Theme',
                onTap: () {
                  // تنفيذ اتباع إعدادات النظام
                  AnimatedToast.show(
                    context: context,
                    message: 'System theme setting will be implemented',
                    type: ToastType.info,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // إعدادات الحساب
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('account') ?? 'Account',
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.person,
                title: localizations.translate('profile') ?? 'Profile',
                onTap: () {
                  // التحقق مما إذا كان المستخدم مسجل الدخول
                  final authState = BlocProvider.of<AuthBloc>(context).state;
                  if (authState is Authenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProfileScreen(user: authState.user),
                      ),
                    );
                  } else {
                    // إذا لم يكن مسجل الدخول، اعرض رسالة
                    AnimatedToast.show(
                      context: context,
                      message:
                          localizations.translate('login_required') ??
                          'Login required',
                      type: ToastType.warning,
                    );

                    // انتقل إلى صفحة تسجيل الدخول
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.notifications,
                title:
                    localizations.translate('notifications') ?? 'Notifications',
                trailing: Switch(
                  value: true, // يمكن استبدالها بقيمة من BLoC
                  onChanged: (value) {
                    // تنفيذ تغيير إعدادات الإشعارات
                    AnimatedToast.show(
                      context: context,
                      message:
                          value
                              ? localizations.translate(
                                    'notifications_enabled',
                                  ) ??
                                  'Notifications enabled'
                              : localizations.translate(
                                    'notifications_disabled',
                                  ) ??
                                  'Notifications disabled',
                      type: ToastType.success,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  // لا شيء هنا لأن الزر يتعامل مع الحدث
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // إعدادات التطبيق
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('app_settings') ?? 'App Settings',
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.shopping_cart,
                title:
                    localizations.translate('shopping_cart') ?? 'Shopping Cart',
                onTap: () {
                  // انتقل إلى إعدادات سلة التسوق
                  AnimatedToast.show(
                    context: context,
                    message: 'Shopping cart settings will be implemented',
                    type: ToastType.info,
                  );
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.payment,
                title:
                    localizations.translate('payment_methods') ??
                    'Payment Methods',
                onTap: () {
                  // انتقل إلى إعدادات طرق الدفع
                  AnimatedToast.show(
                    context: context,
                    message: 'Payment methods settings will be implemented',
                    type: ToastType.info,
                  );
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.location_on,
                title:
                    localizations.translate('shipping_address') ??
                    'Shipping Address',
                onTap: () {
                  // انتقل إلى إعدادات عنوان الشحن
                  AnimatedToast.show(
                    context: context,
                    message: 'Shipping address settings will be implemented',
                    type: ToastType.info,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // حول التطبيق
          _buildSettingsGroup(
            context: context,
            title: localizations.translate('about') ?? 'About',
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.info,
                title: localizations.translate('app_name') ?? '3MCode Shop',
                subtitle: 'v1.0.0',
                onTap: () {
                  // انتقل إلى صفحة حول التطبيق
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutAppScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.star,
                title: localizations.translate('rate_app') ?? 'Rate App',
                onTap: () {
                  // فتح صفحة تقييم التطبيق
                  AnimatedToast.show(
                    context: context,
                    message: 'Rate app feature will be implemented',
                    type: ToastType.info,
                  );
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.share,
                title: localizations.translate('share_app') ?? 'Share App',
                onTap: () {
                  // مشاركة التطبيق
                  AnimatedToast.show(
                    context: context,
                    message: 'Share app feature will be implemented',
                    type: ToastType.info,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // WooCommerce
          _buildSettingsGroup(
            context: context,
            title: 'WooCommerce',
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.shopping_bag,
                title:
                    localizations.translate('woocommerce_products') ??
                    'WooCommerce Products',
                onTap: () {
                  // انتقل إلى صفحة منتجات WooCommerce
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WooProductsScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                context: context,
                icon: Icons.sync,
                title:
                    localizations.translate('sync_settings') ?? 'Sync Settings',
                onTap: () {
                  // تنفيذ إعدادات المزامنة
                  AnimatedToast.show(
                    context: context,
                    message: 'Sync settings will be implemented',
                    type: ToastType.info,
                  );
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
