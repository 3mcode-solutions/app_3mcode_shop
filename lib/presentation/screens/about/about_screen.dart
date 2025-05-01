import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/constants/assets_paths.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // Logo
              SvgPicture.asset(
                AssetPaths.mainLogo,
                width: 120,
                height: 120,
              ),
              
              const SizedBox(height: 24),
              
              // App name
              const Text(
                '3MCode Shop',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // App version
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // About section
              _buildSection(
                title: 'About Us',
                content: 'Welcome to 3MCode Shop, your one-stop destination for fresh groceries and household essentials. We are committed to providing high-quality products at affordable prices, delivered right to your doorstep.',
              ),
              
              const SizedBox(height: 24),
              
              // Mission section
              _buildSection(
                title: 'Our Mission',
                content: 'Our mission is to make grocery shopping convenient, affordable, and enjoyable for everyone. We believe in sustainable practices and supporting local farmers and producers.',
              ),
              
              const SizedBox(height: 24),
              
              // Features section
              _buildSection(
                title: 'App Features',
                content: '',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem('Browse a wide range of products'),
                    _buildFeatureItem('Easy search and filter options'),
                    _buildFeatureItem('Secure checkout process'),
                    _buildFeatureItem('Order tracking'),
                    _buildFeatureItem('Save favorite products'),
                    _buildFeatureItem('Exclusive deals and discounts'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Contact section
              _buildSection(
                title: 'Contact Us',
                content: '',
                child: Column(
                  children: [
                    _buildContactItem(
                      Icons.email_outlined,
                      'Email',
                      'support@3mcodeshop.com',
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      Icons.phone_outlined,
                      'Phone',
                      '+1 (123) 456-7890',
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      Icons.location_on_outlined,
                      'Address',
                      '123 Main Street, City, Country',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Social media links
              const Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, 'Facebook'),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.camera_alt_outlined, 'Instagram'),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.message_outlined, 'Twitter'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Copyright
              Text(
                '© 2025 3MCode Shop. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required String content,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (content.isNotEmpty)
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        if (child != null) ...[
          const SizedBox(height: 8),
          child,
        ],
      ],
    );
  }
  
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSocialButton(IconData icon, String platform) {
    return InkWell(
      onTap: () {
        // Social media link functionality would be implemented here
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}
