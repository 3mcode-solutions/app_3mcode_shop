import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/core/localization/language_manager.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final currentLocale = state.locale;
          final isEnglish = currentLocale.languageCode == 'en';

          return GestureDetector(
            onTap: () => _showLanguageDialog(context, currentLocale),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEnglish ? '🇺🇸' : '🇸🇦',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEnglish ? 'English' : 'العربية',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showLanguageDialog(BuildContext context, Locale currentLocale) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.translate('change_language')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context: context,
                  locale: const Locale('en'),
                  currentLocale: currentLocale,
                  name: 'English',
                  flag: '🇺🇸',
                ),
                const Divider(),
                _buildLanguageOption(
                  context: context,
                  locale: const Locale('ar'),
                  currentLocale: currentLocale,
                  name: 'العربية',
                  flag: '🇸🇦',
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required Locale currentLocale,
    required String name,
    required String flag,
  }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: AppColors.primary)
              : null,
      onTap: () {
        if (!isSelected) {
          context.read<LanguageBloc>().add(ChangeLanguage(locale));

          // Show toast
          AnimatedToast.show(
            context: context,
            message: AppLocalizations.of(context).translate('language_changed'),
            type: ToastType.success,
          );

          // Close dialog
          Navigator.of(context).pop();
        }
      },
    );
  }
}
