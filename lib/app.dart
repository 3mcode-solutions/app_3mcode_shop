import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/core/localization/language_manager.dart';
import 'package:app_3mcode_shop/core/theme/app_theme.dart';
import 'package:app_3mcode_shop/data/repositories/repositories.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/screens.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create:
              (context) =>
                  ProductBloc(productRepository: ProductRepository())
                    ..add(const LoadProducts()),
        ),
        BlocProvider<CategoryBloc>(
          create:
              (context) =>
                  CategoryBloc(categoryRepository: CategoryRepository())
                    ..add(const LoadCategories()),
        ),
        BlocProvider<CartBloc>(
          create:
              (context) =>
                  CartBloc(cartRepository: CartRepository())
                    ..add(const LoadCart()),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc()..add(const LoadLanguage()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          Locale locale = const Locale('en');

          if (state is LanguageLoaded) {
            locale = state.locale;
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: locale,
            supportedLocales: LanguageManager.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
