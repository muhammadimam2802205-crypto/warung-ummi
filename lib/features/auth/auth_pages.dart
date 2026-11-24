import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/brand_mark.dart';
import '../../state/providers.dart';

/// Halaman registrasi dengan bahasa visual yang sama seperti login:
/// latar restoran hangat, kartu cream, field pill, dan tombol gradient.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final error = ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.espresso,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _RegisterBackdrop()),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _GlassIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => context.pop(),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Text(
                            'AKUN PELANGGAN',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: Color(0xCCF6E7D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _RegisterBrand(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: _RegisterCard(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          confirmController: _confirmController,
                          obscure: _obscure,
                          loading: _loading,
                          error: _error,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                          onSubmit: _register,
                          onLogin: () => context.pop(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 + media.padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBackdrop extends StatelessWidget {
  const _RegisterBackdrop();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A2E20),
                  Color(0xFF2A1B13),
                  Color(0xFF1C120E),
                ],
              ),
            ),
          ),
          Transform.scale(
            scale: 1.12,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image.asset(
                'assets/images/products/burger.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                color: const Color(0xB32A1B13),
                colorBlendMode: BlendMode.multiply,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x40241410),
                  Color(0xB32A1B13),
                  Color(0xF21C120E),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.22),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBrand extends StatelessWidget {
  const _RegisterBrand();

  @override
  Widget build(BuildContext context) {
    return const BrandMark(width: 200, onDark: true, showGlow: false);
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmController,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xCCFFFFFF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D2C1B13),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x262C1B13),
            blurRadius: 54,
            offset: Offset(0, 28),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.4,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Daftar untuk mulai memesan di Kedai Ummi',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.brownSoft,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Akun admin tidak dapat dibuat dari halaman ini. Role admin diberikan oleh pengelola kedai.',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: nameController,
              label: 'Nama lengkap',
              hint: 'Nama Anda',
              icon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: emailController,
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.mail_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: phoneController,
              label: 'Nomor HP',
              hint: '08xxxxxxxxxx',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().length < 9) {
                  return 'Nomor HP tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: passwordController,
              label: 'Kata sandi',
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_rounded,
              obscureText: obscure,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Kata sandi minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: confirmController,
              label: 'Ulangi kata sandi',
              icon: Icons.lock_rounded,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              validator: (value) {
                if (value != passwordController.text) {
                  return 'Kata sandi tidak sama';
                }
                return null;
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            AppButton(
              label: 'Daftar Sekarang',
              onPressed: onSubmit,
              loading: loading,
              icon: Icons.person_add_alt_1_rounded,
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brownSoft,
                  ),
                ),
                TextButton(onPressed: onLogin, child: const Text('Masuk')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFFF6E7D2)),
        ),
      ),
    );
  }
}
