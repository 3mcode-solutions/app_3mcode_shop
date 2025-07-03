import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/screens/account/profile_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/login_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/cart/cart_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/favorite/favorites_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/orders/orders_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/settings/settings_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/courses_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الصفحة الرئيسية'),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة الجانبية
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('الفئات'),
            onTap: () {
              Navigator.pop(context);
              // يمكن إضافة التنقل إلى صفحة الفئات هنا
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('الكورسات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoursesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('المفضلة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('سلة التسوق'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('حسابي'),
            onTap: () {
              Navigator.pop(context);
              // التحقق مما إذا كان المستخدم مسجل دخول
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: authState.user),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('طلباتي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;
        final user = isAuthenticated ? (state as Authenticated).user : null;

        return DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage:
                    isAuthenticated && user != null && user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child:
                    (isAuthenticated && user != null && user.photoUrl != null)
                        ? null
                        : const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
              ),
              const SizedBox(height: 10),
              Text(
                isAuthenticated && user != null ? user.name : 'مرحبًا بك!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isAuthenticated && user != null
                    ? user.email
                    : 'تسجيل الدخول للوصول إلى جميع الميزات',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
