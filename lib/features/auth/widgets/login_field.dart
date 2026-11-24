import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_motion.dart';

/// Input field login dengan transisi fokus halus (200 ms).
class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.hint,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final String hint;
  final FormFieldValidator<String> validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final duration = adaptiveDuration(
      context,
      const Duration(milliseconds: 200),
    );

    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(
          color: focused ? AppColors.terracotta : AppColors.beige,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: focused
                ? AppColors.terracotta.withValues(alpha: 0.16)
                : AppColors.brown.withValues(alpha: 0.05),
            blurRadius: focused ? 18 : 10,
            offset: Offset(0, focused ? 6 : 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        cursorColor: AppColors.terracotta,
        autocorrect: false,
        enableSuggestions: !obscureText,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.brown,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA38F80),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 11, 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: focused ? 0 : 1,
                end: focused ? 1 : 0,
              ),
              duration: duration,
              curve: AppMotion.standard,
              builder: (context, value, _) => Icon(
                icon,
                size: 20,
                color: Color.lerp(
                  const Color(0xFF9B8574),
                  AppColors.terracotta,
                  value,
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.fromLTRB(0, 18, 14, 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(
            fontSize: 11,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.danger,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
