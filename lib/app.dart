import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
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
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
