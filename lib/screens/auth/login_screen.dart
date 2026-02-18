import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

// ─── Login Screen ─────────────────────────────────────────────────────────────
// Supports: OAuth (Google, Apple, Facebook), Phone OTP, Email + Password

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _tabController.dispose();
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
                  // ── OAuth ────────────────────────────────────────────────
                  _buildOAuthSection(context),
                  const SizedBox(height: 28),
                  _buildDivider(context),
                  const SizedBox(height: 28),
                  // ── Email / Phone Tabs ───────────────────────────────────
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 310,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEmailLoginForm(context),
                        _buildPhoneLoginForm(context),
                      ],
                    ),
                  ),
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

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome Back',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue your draping journey',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── OAuth Section ────────────────────────────────────────────────────────

  Widget _buildOAuthSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isOAuthLoading = auth.state == AuthState.loading &&
            (auth.loginMethod == 'google' ||
                auth.loginMethod == 'apple' ||
                auth.loginMethod == 'facebook');

        return Column(
          children: [
            _OAuthButton(
              icon: _GoogleIcon(),
              label: 'Continue with Google',
              isLoading:
                  auth.state == AuthState.loading && auth.loginMethod == 'google',
              onTap: () async {
                auth.setLoginMethod('google');
                final ok = await auth.loginWithSocial('Google');
                if (ok && mounted) {
                  if (context.mounted) context.go('/onboarding');
                }
              },
            ),
            const SizedBox(height: 12),
            _OAuthButton(
              icon: const Icon(Icons.apple, color: Colors.white, size: 22),
              label: 'Continue with Apple',
              isLoading:
                  auth.state == AuthState.loading && auth.loginMethod == 'apple',
              onTap: () async {
                auth.setLoginMethod('apple');
                final ok = await auth.loginWithSocial('Apple');
                if (ok && mounted) {
                  if (context.mounted) context.go('/onboarding');
                }
              },
            ),
            const SizedBox(height: 12),
            _OAuthButton(
              icon: const Icon(Icons.facebook,
                  color: Color(0xFF4267B2), size: 22),
              label: 'Continue with Facebook',
              isLoading:
                  auth.state == AuthState.loading && auth.loginMethod == 'facebook',
              onTap: () async {
                auth.setLoginMethod('facebook');
                final ok = await auth.loginWithSocial('Facebook');
                if (ok && mounted) {
                  if (context.mounted) context.go('/onboarding');
                }
              },
            ),
            if (auth.errorMessage != null && isOAuthLoading == false &&
                (auth.loginMethod == 'google' ||
                    auth.loginMethod == 'apple' ||
                    auth.loginMethod == 'facebook')) ...[
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
            'or sign in with',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textHint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, size: 16),
                SizedBox(width: 6),
                Text('Email'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_outlined, size: 16),
                SizedBox(width: 6),
                Text('Phone OTP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Email Form ───────────────────────────────────────────────────────────

  Widget _buildEmailLoginForm(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _emailFormKey,
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
                  if (!v.contains('@')) return 'Please enter a valid email';
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
                  if (v == null || v.isEmpty) return 'Please enter your password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {/* TODO: forgot password */},
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
                Text(auth.errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.state == AuthState.loading
                      ? null
                      : () async {
                          auth.setLoginMethod('email');
                          if (_emailFormKey.currentState?.validate() ??
                              false) {
                            final ok = await auth.loginWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (ok && context.mounted) context.go('/onboarding');
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

  // ─── Phone / OTP Form ─────────────────────────────────────────────────────

  Widget _buildPhoneLoginForm(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          children: [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: AppStrings.mobileNumber,
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 14),
            if (auth.isOtpSent) ...[
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: AppStrings.enterOtp,
                  prefixIcon: Icon(Icons.pin_outlined),
                  counterText: '',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    auth.setLoginMethod('phone');
                    auth.sendOtp(_phoneController.text.trim());
                  },
                  child: const Text(AppStrings.resendOtp,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primaryLight)),
                ),
              ),
            ] else
              const SizedBox(height: 20),
            if (auth.errorMessage != null &&
                auth.loginMethod == 'phone') ...[
              const SizedBox(height: 4),
              Text(auth.errorMessage!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.state == AuthState.loading
                    ? null
                    : () async {
                        auth.setLoginMethod('phone');
                        if (!auth.isOtpSent) {
                          await auth.sendOtp(
                              _phoneController.text.trim());
                        } else {
                          final ok = await auth.verifyOtp(
                            _phoneController.text.trim(),
                            _otpController.text.trim(),
                          );
                          if (ok && context.mounted) context.go('/onboarding');
                        }
                      },
                child: auth.state == AuthState.loading &&
                        auth.loginMethod == 'phone'
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(auth.isOtpSent
                        ? AppStrings.verifyOtp
                        : AppStrings.sendOtp),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Sign-up Link ─────────────────────────────────────────────────────────

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(AppStrings.dontHaveAccount,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text(AppStrings.signUp,
              style: TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─── OAuth Button ─────────────────────────────────────────────────────────────

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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryLight),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Google 'G' Icon ──────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFFDB4437),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
