import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.translate('theme_settings'),
        showBackButton: true,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // شرح الوضع الداكن
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.translate('appearance'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('dark_mode_description'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // خيارات الوضع الداكن
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // الوضع الفاتح
                    _buildThemeOption(
                      context,
                      icon: Icons.light_mode,
                      title: localizations.translate('light_mode'),
                      subtitle: localizations.translate('light_mode_description'),
                      isSelected: !isDarkMode,
                      onTap: () {
                        if (isDarkMode) {
                          context.read<ThemeBloc>().add(const SetLightTheme());
                          _showThemeChangedToast(context, isDark: false);
                        }
                      },
                    ),
                    
                    const Divider(height: 1),
                    
                    // الوضع الداكن
                    _buildThemeOption(
                      context,
                      icon: Icons.dark_mode,
                      title: localizations.translate('dark_mode'),
                      subtitle: localizations.translate('dark_mode_description'),
                      isSelected: isDarkMode,
                      onTap: () {
                        if (!isDarkMode) {
                          context.read<ThemeBloc>().add(const SetDarkTheme());
                          _showThemeChangedToast(context, isDark: true);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // فوائد الوضع الداكن
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('dark_mode_benefits'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        context,
                        icon: Icons.battery_charging_full,
                        title: localizations.translate('battery_saving'),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        context,
                        icon: Icons.remove_red_eye,
                        title: localizations.translate('eye_comfort'),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        context,
                        icon: Icons.nightlight_round,
                        title: localizations.translate('night_reading'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: isSelected,
              groupValue: true,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
  
  void _showThemeChangedToast(BuildContext context, {required bool isDark}) {
    final localizations = AppLocalizations.of(context);
    
    AnimatedToast.show(
      context: context,
      message: isDark
          ? localizations.translate('dark_mode_enabled')
          : localizations.translate('light_mode_enabled'),
      type: ToastType.success,
    );
  }
}
