import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/user_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_text_field.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
    _photoUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _photoUrl = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        AnimatedToast.show(
          context: context,
          message: localizations.translate('failed_to_pick_image'),
          type: ToastType.error,
        );
      }
    }
  }

  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        UpdateUserProfile(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          photoUrl: _photoUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.translate('profile'),
        showBackButton: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            AnimatedToast.show(
              context: context,
              message: localizations.translate('profile_updated_successfully'),
              type: ToastType.success,
            );
          } else if (state is ProfileUpdateError) {
            AnimatedToast.show(
              context: context,
              message: state.message,
              type: ToastType.error,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 24),
                _buildProfileForm(localizations),
                const SizedBox(height: 24),
                _buildUpdateButton(localizations),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getProfileImage(),
                  child:
                      _getProfileImage() == null
                          ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_photoUrl != null) {
      if (_photoUrl!.startsWith('/')) {
        return FileImage(File(_photoUrl!));
      } else {
        return NetworkImage(_photoUrl!);
      }
    }
    return null;
  }

  Widget _buildProfileForm(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('personal_information'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          controller: _nameController,
          label: localizations.translate('full_name'),
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.translate('name_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          controller: _emailController,
          label: localizations.translate('email'),
          prefixIcon: Icons.email,
          enabled: false, // Email cannot be changed
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          controller: _phoneController,
          label: localizations.translate('phone_number'),
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Phone is optional
            }
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
              return localizations.translate('invalid_phone');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton(AppLocalizations localizations) {
    return AnimatedButton(
      onPressed: _updateProfile,
      text: localizations.translate('update_profile'),
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 10,
      height: 50,
    );
  }
}
