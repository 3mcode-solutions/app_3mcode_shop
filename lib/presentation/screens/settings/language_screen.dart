import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/core/localization/language_manager.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.translate('language'),
        showBackButton: true,
      ),
      body: BlocConsumer<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageLoaded) {
            // Show toast when language is changed
            AnimatedToast.show(
              context: context,
              message: localizations.translate('language_changed'),
              type: ToastType.success,
            );

            // Restart app to apply language changes
            // In a real app, you would use a more sophisticated approach
            // like Phoenix package to restart the app
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is LanguageLoaded) {
            return _buildLanguageList(context, state.locale);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context, Locale currentLocale) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLanguageItem(
          context: context,
          locale: const Locale('en'),
          currentLocale: currentLocale,
          name: localizations.translate('english'),
          flag: '🇺🇸',
        ),
        const Divider(),
        _buildLanguageItem(
          context: context,
          locale: const Locale('ar'),
          currentLocale: currentLocale,
          name: localizations.translate('arabic'),
          flag: '🇸🇦',
        ),
      ],
    );
  }

  Widget _buildLanguageItem({
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
        }
      },
    );
  }
}
