import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_text_field.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('register')),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            AnimatedToast.show(
              context: context,
              message: localizations.translate('registration_success'),
              type: ToastType.success,
            );
            Navigator.of(context).pop();
          } else if (state is RegistrationError) {
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
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildNameField(localizations),
                const SizedBox(height: 16),
                _buildEmailField(localizations),
                const SizedBox(height: 16),
                _buildPhoneField(localizations),
                const SizedBox(height: 16),
                _buildPasswordField(localizations),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(localizations),
                const SizedBox(height: 24),
                _buildRegisterButton(localizations),
                const SizedBox(height: 16),
                _buildLoginLink(context, localizations),
                const SizedBox(height: 30),
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

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '3M',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _nameController,
      label: localizations.translate('full_name'),
      hint: localizations.translate('enter_full_name'),
      prefixIcon: Icons.person,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('name_required');
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _emailController,
      label: localizations.translate('email'),
      hint: localizations.translate('enter_email'),
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('email_required');
        }
        if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return localizations.translate('invalid_email');
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _phoneController,
      label: localizations.translate('phone_number'),
      hint: localizations.translate('enter_phone_number'),
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
    );
  }

  Widget _buildPasswordField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _passwordController,
      label: localizations.translate('password'),
      hint: localizations.translate('enter_password'),
      prefixIcon: Icons.lock,
      suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: _togglePasswordVisibility,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('password_required');
        }
        if (value.length < 6) {
          return localizations.translate('password_too_short');
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _confirmPasswordController,
      label: localizations.translate('confirm_password'),
      hint: localizations.translate('enter_confirm_password'),
      prefixIcon: Icons.lock_outline,
      suffixIcon:
          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: _toggleConfirmPasswordVisibility,
      obscureText: _obscureConfirmPassword,
      onSubmitted: (_) => _register(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('confirm_password_required');
        }
        if (value != _passwordController.text) {
          return localizations.translate('passwords_do_not_match');
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(AppLocalizations localizations) {
    return AnimatedButton(
      onPressed: _register,
      text: localizations.translate('register'),
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 10,
      height: 50,
    );
  }

  Widget _buildLoginLink(BuildContext context, AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(localizations.translate('already_have_account')),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            localizations.translate('login'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
