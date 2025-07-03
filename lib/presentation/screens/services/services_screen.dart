import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/services/services_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
    final services = ServicesService.getMainServices();
    return RepaintBoundary(
      key: _repaintKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('خدماتنا')),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            if (Navigator.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث قائمة الخدمات بنجاح!')),
              );
            }
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailsScreen(service: service),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(service.icon, size: 36, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service.shortDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            },
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
}

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceItem service;
  const ServiceDetailsScreen({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تقسيم الوصف إلى نقاط
    final List<String> bullets = service.description.split('\n- ');
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(service.icon, size: 56, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              service.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (bullets.isNotEmpty)
              Text(
                bullets[0],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (bullets.length > 1) ...[
              const SizedBox(height: 16),
              Text('مميزات الخدمة:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...bullets.sublist(1).map((b) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 20)),
                  Expanded(child: Text(b.trim(), style: Theme.of(context).textTheme.bodyMedium)),
                ],
              )),
            ],
            const SizedBox(height: 32),
            // زر تواصل أو طلب الخدمة (يمكنك ربطه لاحقاً)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: ربط بفورم تواصل أو صفحة طلب الخدمة
                },
                icon: const Icon(Icons.send),
                label: const Text('تواصل معنا بخصوص هذه الخدمة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceContactForm extends StatefulWidget {
  final String serviceTitle;
  const _ServiceContactForm({Key? key, required this.serviceTitle}) : super(key: key);

  @override
  State<_ServiceContactForm> createState() => _ServiceContactFormState();
}

class _ServiceContactFormState extends State<_ServiceContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: localizations.translate('full_name'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('name_required');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: localizations.translate('email'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('email_required');
              }
              if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4} $').hasMatch(value)) {
                return localizations.translate('email_invalid');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: localizations.translate('phone'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('phone_required');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: localizations.translate('message'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.message),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('message_required');
              }
              if (value.length < 10) {
                return localizations.translate('message_too_short');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context).translate('send_message')),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    // هنا يمكنك إرسال البيانات إلى بريدك أو API
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('message_sent_success')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
    }
  }
}

class ServicesImagesGalleryScreen extends StatelessWidget {
  const ServicesImagesGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List all image files in assets/services (hardcoded for now, can be automated)
    final List<String> imageFiles = [
      'assets/services/a-behance-cover-design-with-the-dimensio_aArIfxGxQX6h75EH6Zu3rA_lOKxtn-iSZ-jJjcUz0KNLA.jpeg',
      'assets/services/a-behance-cover-design-with-the-dimensio_Q5l3mQ9IRNulieTGFQaVog_lOKxtn-iSZ-jJjcUz0KNLA.jpeg',
      'assets/services/a-professional-behance-cover-design-with_9yUfcXSJSrea9gkKQQqPBA_lOKxtn-iSZ-jJjcUz0KNLA.jpeg',
      'assets/services/a-professional-behance-cover-design-with_5QX12C8ITGiLNLQtf6jXcw_lOKxtn-iSZ-jJjcUz0KNLA.jpeg',
      'assets/services/a-clean-professional-infographic-with-th__zDeCfUmTjarJBKiuEYzLQ_5HlMc8omTGit8Q1JZB0NqA.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_3-3KOTBXR7mTN6_XWpFBfw_5HlMc8omTGit8Q1JZB0NqA.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_M5hgWq8mS8OQ82qNgcugMQ_5HlMc8omTGit8Q1JZB0NqA.jpeg',
      'assets/services/a-clean-professional-infographic-with-a-_L691CU5vQJay43FazV_NzQ_5HlMc8omTGit8Q1JZB0NqA.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_7JJrqvcKQJuic9Cj0HzAuQ_IHpGS-aNS2aLCJFIEyBkzg.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_jCUJRt-JR_65QsxhZz20dQ_IHpGS-aNS2aLCJFIEyBkzg.jpeg',
      'assets/services/a-clean-professional-infographic-with-a-_k_Elc1SqS-2gzlyhCiqsTg_IHpGS-aNS2aLCJFIEyBkzg.jpeg',
      'assets/services/a-clean-professional-infographic-with-a-_kmDTPOidRTi3AGglGqZstQ_IHpGS-aNS2aLCJFIEyBkzg.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_9vMbNDAnTXOZ22yhKlJAOA_YfHCKUZ5SJyc4S2IGxMzAw.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_4pMgaOZgSb2lh5FUHWt1aw_YfHCKUZ5SJyc4S2IGxMzAw.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_Mebk1o9LTne3v-y6hSe0Hw_TuxhPTktSHqB8g6WB6n4Lg.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_6jCYMZVJR6alFc_y04NKDg_TuxhPTktSHqB8g6WB6n4Lg.jpeg',
      'assets/services/a-clean-professional-infographic-with-a-_hS4N9JWWReaXzXB9GFIyWQ_HL0lih8DTqOXP5OYgB0b-g.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_aN3e4kW5QWOPmotUiHleQA_HL0lih8DTqOXP5OYgB0b-g.jpeg',
      'assets/services/a-clean-professional-infographic-with-th_Yoztr8gJT3Wu1TDAXSja5g_HL0lih8DTqOXP5OYgB0b-g.jpeg',
      // ... أضف باقي الصور هنا حسب الحاجة ...
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('معرض صور الخدمات')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          final img = imageFiles[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    img.split('/').last,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 