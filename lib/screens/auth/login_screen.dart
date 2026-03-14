import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 480 : double.infinity),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildOAuthSection(context),
                  const SizedBox(height: 28),
                  _buildDivider(context),
                  const SizedBox(height: 28),
                  _buildEmailForm(context),
                  const SizedBox(height: 24),
                  _buildSignUpLink(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: const Text(
            'MEMBER ACCESS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome back',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your saree try-ons and saved looks.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOAuthSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          children: [
            _OAuthButton(
              icon: _GoogleIcon(),
              label: 'Continue with Google',
              isLoading: auth.state == AuthState.loading &&
                  auth.loginMethod == 'google',
              onTap: () async {
                auth.setLoginMethod('google');
                final ok = await auth.loginWithSocial('Google');
                if (ok && mounted) {
                  if (context.mounted) context.go('/onboarding');
                }
              },
            ),
            if (auth.errorMessage != null &&
                auth.state != AuthState.loading &&
                auth.loginMethod == 'google') ...[
              const SizedBox(height: 10),
              Text(
                auth.errorMessage!,
                style:
                    const TextStyle(color: AppColors.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.12,
                ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@'))
                    return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Please enter your password';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                        color: AppColors.primaryLight, fontSize: 12),
                  ),
                ),
              ),
              if (auth.errorMessage != null &&
                  auth.loginMethod == 'email') ...[
                const SizedBox(height: 4),
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.state == AuthState.loading
                      ? null
                      : () async {
                          auth.setLoginMethod('email');
                          if (_formKey.currentState?.validate() ?? false) {
                            final ok = await auth.loginWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (ok && context.mounted) {
                              context.go('/onboarding');
                            }
                          }
                        },
                  child: auth.state == AuthState.loading &&
                          auth.loginMethod == 'email'
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.login),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: const Text(
            AppStrings.signUp,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ── OAuth Button ──────────────────────────────────────────────────────────────

class _OAuthButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD8DDE6)),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 22, height: 22, child: icon),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://www.google.com/favicon.ico',
      width: 20,
      height: 20,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.g_mobiledata, color: Colors.white, size: 22),
    );
  }
}
