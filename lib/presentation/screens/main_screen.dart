import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const CartScreen(),
    const AboutScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int cartItemCount = 0;

            if (state is CartLoaded) {
              cartItemCount = state.totalQuantity;
            }

            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context).translate('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_bag),
                  label: AppLocalizations.of(context).translate('products'),
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartItemCount > 9 ? '9+' : '$cartItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: AppLocalizations.of(context).translate('cart'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.info),
                  label: AppLocalizations.of(context).translate('about'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: AppLocalizations.of(context).translate('settings'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
