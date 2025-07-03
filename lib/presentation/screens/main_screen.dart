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
    const ServicesScreen(),
    const PortfolioScreen(),
    const AboutScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context).translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build),
              label: AppLocalizations.of(context).translate('services'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.work),
              label: AppLocalizations.of(context).translate('portfolio'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.info),
              label: AppLocalizations.of(context).translate('about'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.phone),
              label: AppLocalizations.of(context).translate('contact'),
            ),
          ],
        ),
      ),
    );
  }
}
