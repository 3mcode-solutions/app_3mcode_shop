import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/register_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_text_field.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('login')),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            AnimatedToast.show(
              context: context,
              message: localizations.translate('login_success'),
              type: ToastType.success,
            );
            Navigator.of(context).pop();
          } else if (state is LoginError) {
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
                const SizedBox(height: 40),
                _buildEmailField(localizations),
                const SizedBox(height: 16),
                _buildPasswordField(localizations),
                const SizedBox(height: 8),
                _buildForgotPassword(localizations),
                const SizedBox(height: 24),
                _buildLoginButton(localizations),
                const SizedBox(height: 16),
                _buildRegisterLink(context, localizations),
                const SizedBox(height: 40),
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

  Widget _buildPasswordField(AppLocalizations localizations) {
    return AnimatedTextField(
      controller: _passwordController,
      label: localizations.translate('password'),
      hint: localizations.translate('enter_password'),
      prefixIcon: Icons.lock,
      suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: _togglePasswordVisibility,
      obscureText: _obscurePassword,
      onSubmitted: (_) => _login(),
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

  Widget _buildForgotPassword(AppLocalizations localizations) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Navigate to forgot password screen
          AnimatedToast.show(
            context: context,
            message: localizations.translate('feature_coming_soon'),
            type: ToastType.info,
          );
        },
        child: Text(localizations.translate('forgot_password')),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations localizations) {
    return AnimatedButton(
      onPressed: _login,
      text: localizations.translate('login'),
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 10,
      height: 50,
    );
  }

  Widget _buildRegisterLink(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(localizations.translate('dont_have_account')),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            localizations.translate('register'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
