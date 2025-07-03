import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/constants/assets_paths.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/repositories/product_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/cart/cart_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/login_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/account/profile_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/favorite/favorites_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_list_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/settings/theme_settings_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/woo_products_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/courses_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/course_details_screen.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _saveScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory('${directory.path}/screenshots');
      if (!screenshotsDir.existsSync()) {
        screenshotsDir.createSync(recursive: true);
      }
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${screenshotsDir.path}/screenshot_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ صورة الشاشة في: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التقاط الصورة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return RepaintBoundary(
      key: _repaintKey,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: SvgPicture.asset(
                  'assets/logo/logo.svg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => const Icon(Icons.image, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '3M Code Solutions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Handle notifications
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            if (Navigator.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الصفحة الرئيسية!')),
              );
            }
          },
          child: ListView(
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    ClipOval(
                      child: SvgPicture.asset(
                        'assets/logo/logo.svg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => const Icon(Icons.image, size: 80, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localizations.translate('company_tagline'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('services_description'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to services
                        Navigator.pushNamed(context, '/services');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localizations.translate('our_services')),
                    ),
                  ],
                ),
              ),
              
              // Statistics Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatistic(context, '50+', localizations.translate('projects_completed')),
                    _buildStatistic(context, '30+', localizations.translate('happy_clients')),
                    _buildStatistic(context, '5+', localizations.translate('years_experience')),
                  ],
                ),
              ),
              
              // Featured Services
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('our_services'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('services_description'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFeaturedServices(context),
                  ],
                ),
              ),
              
              // Latest Projects
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('our_work'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('portfolio_description'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLatestProjects(context),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/portfolio');
                        },
                        child: Text(localizations.translate('see_all')),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Why Choose Us
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لماذا تختارنا؟',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildWhyChooseUs(context),
                  ],
                ),
              ),
              
              // Call to Action
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      localizations.translate('ready_to_start'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('contact_us_description'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/contact');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(localizations.translate('contact_us')),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/about');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(localizations.translate('about')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveScreenshot,
          child: const Icon(Icons.camera_alt),
          tooltip: 'التقاط صورة للشاشة',
        ),
      ),
    );
  }

  Widget _buildStatistic(BuildContext context, String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturedServices(BuildContext context) {
    final services = [
      {
        'icon': Icons.web,
        'title': 'تطوير المواقع',
        'description': 'مواقع احترافية متجاوبة',
        'color': Colors.blue,
      },
      {
        'icon': Icons.phone_android,
        'title': 'تطوير التطبيقات',
        'description': 'تطبيقات جوال عالية الأداء',
        'color': Colors.green,
      },
      {
        'icon': Icons.trending_up,
        'title': 'التسويق الرقمي',
        'description': 'حملات تسويقية فعالة',
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/services');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (service['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      size: 32,
                      color: service['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service['title'] as String,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLatestProjects(BuildContext context) {
    final projects = [
      {
        'title': 'موقع شركة تجارية',
        'category': 'تطوير المواقع',
        'image': 'assets/portfolio/project1.jpg',
      },
      {
        'title': 'تطبيق طلبات الطعام',
        'category': 'تطوير التطبيقات',
        'image': 'assets/portfolio/project2.jpg',
      },
      {
        'title': 'حملة تسويقية رقمية',
        'category': 'التسويق الرقمي',
        'image': 'assets/portfolio/project3.jpg',
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/portfolio');
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: project['image'] != null
                              ? Image.asset(
                                  project['image'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image,
                                        size: 48,
                                        color: Colors.grey[500],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey[500],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project['title'] as String,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              project['category'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhyChooseUs(BuildContext context) {
    final reasons = [
      {
        'icon': Icons.verified,
        'title': 'الجودة العالية',
        'description': 'نلتزم بأعلى معايير الجودة في جميع مشاريعنا',
      },
      {
        'icon': Icons.schedule,
        'title': 'الالتزام بالمواعيد',
        'description': 'نحترم مواعيدنا ونلتزم بتسليم المشاريع في الوقت المحدد',
      },
      {
        'icon': Icons.support_agent,
        'title': 'الدعم المستمر',
        'description': 'نقدم دعم فني مستمر لجميع عملائنا',
      },
      {
        'icon': Icons.lightbulb,
        'title': 'الابتكار',
        'description': 'نستخدم أحدث التقنيات والحلول المبتكرة',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: reasons.length,
      itemBuilder: (context, index) {
        final reason = reasons[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  reason['icon'] as IconData,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  reason['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  reason['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
