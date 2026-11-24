import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/premium_motion.dart';
import '../../../state/providers.dart';
import 'login_field.dart';

/// Kartu login utama: panel cream yang terangkat di atas latar gelap.
///
/// Semua fungsi autentikasi tetap memakai [authProvider] yang sudah ada:
/// login email/nomor HP, ingat sesi, lupa kata sandi, dan masuk sebagai tamu.
class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChanged);
    _passwordFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _passwordFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    // Jeda singkat agar transisi tombol terlihat halus, bukan kedip.
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final error = ref
        .read(authProvider.notifier)
        .login(
          _emailController.text,
          _passwordController.text,
          remember: _remember,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }

    TextInput.finishAutofillContext(shouldSave: _remember);
    // Navigasi ditangani otomatis oleh redirect GoRouter saat auth berubah.
  }

  void _loginAsGuest() {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    final error = ref.read(authProvider.notifier).loginAsGuest();
    if (error != null && mounted) {
      setState(() => _error = error);
    }
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.float,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.terracottaSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 27,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Lupa Kata Sandi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Akun dan kata sandi disimpan hanya di perangkat ini. '
                'Hubungi pengelola Kedai Ummi untuk bantuan mengakses akun Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brownSoft,
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Mengerti',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x99140A04).withValues(alpha: 0.6),
            blurRadius: 44,
            offset: const Offset(0, 22),
          ),
          const BoxShadow(
            color: Color(0x4D140A04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.14),
            blurRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Kilau tipis di bibir kartu.
                  Container(
                    height: 1.2,
                    margin: const EdgeInsets.fromLTRB(26, 0, 26, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0x00FFFFFF),
                          Color(0xE6FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                  Reveal(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Selamat Datang 👋',
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.brown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Masuk untuk melanjutkan pesanan Anda',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Reveal(
                    index: 4,
                    offset: 0.03,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _FieldLabel('Email atau Nomor Telepon'),
                        const SizedBox(height: 7),
                        LoginField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          icon: Icons.mail_outline_rounded,
                          hint: 'Masukkan email atau nomor telepon',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[AutofillHints.email],
                          enabled: !_loading,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Email atau nomor telepon wajib diisi';
                            }
                            final isPhone = RegExp(
                              r'^\+?[0-9][0-9\s-]{7,}$',
                            ).hasMatch(text);
                            if (!isPhone && !text.contains('@')) {
                              return 'Format email atau nomor tidak valid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    index: 5,
                    offset: 0.03,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _FieldLabel('Kata Sandi'),
                        const SizedBox(height: 7),
                        LoginField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          icon: Icons.lock_outline_rounded,
                          hint: 'Masukkan kata sandi',
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const <String>[AutofillHints.password],
                          enabled: !_loading,
                          onFieldSubmitted: (_) => _submit(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              color: AppColors.muted,
                              splashRadius: 20,
                              tooltip: _obscure
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kata sandi wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  _ErrorBanner(message: _error),
                  const SizedBox(height: 4),
                  Reveal(
                    index: 6,
                    offset: 0.02,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 2,
                      children: <Widget>[
                        _RememberToggle(
                          value: _remember,
                          onChanged: (value) =>
                              setState(() => _remember = value),
                        ),
                        TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.terracottaDark,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Lupa Kata Sandi?'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Reveal(
                    index: 7,
                    offset: 0.03,
                    child: AppButton(
                      label: 'Masuk',
                      loading: _loading,
                      trailingIcon: Icons.arrow_forward_rounded,
                      trailingIconInCircle: true,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0xFFA65D3F), Color(0xFF85452F)],
                      ),
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Reveal(
                    index: 8,
                    child: const _OrDivider(text: 'Atau masuk dengan'),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    index: 9,
                    child: PressScale(
                      scale: 0.985,
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _loading ? null : _loginAsGuest,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.brown,
                            disabledForegroundColor: AppColors.muted,
                            side: const BorderSide(color: Color(0xFFF0E2D2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.field,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person_outline_rounded,
                                size: 19,
                                color: AppColors.terracottaDark,
                              ),
                              SizedBox(width: 9),
                              Flexible(
                                child: Text(
                                  'Masuk sebagai tamu',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    index: 10,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Belum memiliki akun?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownSoft,
                          ),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => context.push('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.terracottaDark,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                          ),
                          child: const Text('Daftar Sekarang'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.brownSoft,
      ),
    );
  }
}

class _RememberToggle extends StatelessWidget {
  const _RememberToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ingat saya',
      toggled: value,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: adaptiveDuration(
                    context,
                    const Duration(milliseconds: 180),
                  ),
                  curve: AppMotion.standard,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: value ? AppColors.terracotta : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value
                          ? AppColors.terracotta
                          : AppColors.borderStrong,
                      width: 1.4,
                    ),
                    boxShadow: value
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AppColors.terracotta.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: value
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Ingat Saya',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 17,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(color: AppColors.border, height: 1, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.border, height: 1, thickness: 1),
        ),
      ],
    );
  }
}
