import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// KEDAI UMMI — DESIGN TOKENS
/// Konsep: Premium Modern Food Experience
/// Hangat, tenang, editorial, dan berfokus pada makanan.
/// ---------------------------------------------------------------

class AppColors {
  // Canvas — warm cream, hangat dan lembut seperti referensi login.
  static const cream = Color(0xFFFFF8EF);
  static const creamDeep = Color(0xFFF2E5D5);
  static const beige = Color(0xFFE8D8C8);
  static const beigeSoft = Color(0xFFFBF0E3);
  static const terracottaSoft = Color(0xFFF7E7D8);

  // Brand
  static const terracotta = Color(0xFFA65D3F);
  static const terracottaDark = Color(0xFF85452F);
  static const gold = Color(0xFFD6A66A);
  static const espresso = Color(0xFF2A1B13);

  // Text
  static const brown = Color(0xFF38251D);
  static const brownSoft = Color(0xFF6B5445);
  static const muted = Color(0xFF9B8574);

  // Surface — putih hangat dengan sentuhan cream.
  static const white = Color(0xFFFFFCF7);
  static const surface = white;
  static const surfaceAlt = Color(0xFFFBF1E5);
  static const border = Color(0xFFEADCCB);
  static const borderStrong = Color(0xFFDCC7B2);

  // Status
  static const success = Color(0xFF37735A);
  static const successSoft = Color(0xFFE6F1EA);
  static const danger = Color(0xFFB24438);
  static const dangerSoft = Color(0xFFF9E5E1);
  static const warning = Color(0xFF9E7220);
  static const warningSoft = Color(0xFFFAF0D9);
  static const info = Color(0xFF3B6788);
  static const infoSoft = Color(0xFFE6EEF4);

  // Utility
  static const shadow = Color(0x1438251D);
  static const scrim = Color(0x662A1B13);
  static const transparent = Colors.transparent;

  // Gradient siap pakai untuk tombol & elemen utama.
  static const primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB96D43), Color(0xFF8A4429)],
  );

  static const espressoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B2A1F), espresso],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFDF9), Color(0xFFFFF8EF), Color(0xFFFCF2E7)],
  );
}

class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x1438251D), blurRadius: 22, offset: Offset(0, 10)),
  ];

  static const float = <BoxShadow>[
    BoxShadow(color: Color(0x2438251D), blurRadius: 34, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x1038251D), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static const button = <BoxShadow>[
    BoxShadow(color: Color(0x33A65D3F), blurRadius: 18, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x1438251D), blurRadius: 30, offset: Offset(0, 16)),
  ];
}

class AppRadii {
  static const field = 16.0;
  static const button = 20.0;
  static const card = 24.0;
  static const sheet = 32.0;
  static const pill = 999.0;
}

class AppMotion {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);
  static const smooth = Duration(milliseconds: 350);
  static const emphasis = Duration(milliseconds: 500);
  static const reveal = Duration(milliseconds: 520);
  static const cinematic = Duration(milliseconds: 900);
  static const stagger = Duration(milliseconds: 60);

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeOutQuint;
  static const gentle = Curves.easeInOutCubic;
  static const spring = Curves.easeOutBack;
  static const overshoot = Curves.elasticOut;

  /// Hormati pengaturan "kurangi gerakan" milik perangkat.
  static Duration adaptive(BuildContext context, Duration duration) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reduce ? Duration.zero : duration;
  }

  static Duration staggerAt(int index, {Duration step = stagger}) {
    return step * index.clamp(0, 12);
  }
}

const List<String> _fontFallback = <String>[
  'Roboto',
  'Noto Sans',
  'sans-serif',
];

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.brown,
  double height = 1.12,
  double letterSpacing = -0.6,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: _fontFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.terracotta,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.terracottaSoft,
    onPrimaryContainer: AppColors.terracottaDark,
    secondary: AppColors.espresso,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.beigeSoft,
    onSecondaryContainer: AppColors.espresso,
    tertiary: AppColors.gold,
    onTertiary: AppColors.espresso,
    surface: AppColors.surface,
    onSurface: AppColors.brown,
    surfaceContainerHighest: AppColors.beigeSoft,
    error: AppColors.danger,
    onError: AppColors.white,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Poppins',
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: _display(size: 50, letterSpacing: -1.6, height: 1.04),
    displayMedium: _display(size: 42, letterSpacing: -1.3, height: 1.06),
    displaySmall: _display(size: 34, letterSpacing: -1.0),
    headlineLarge: _display(size: 30, letterSpacing: -0.8),
    headlineMedium: _display(size: 26, letterSpacing: -0.7),
    headlineSmall: _display(size: 22, letterSpacing: -0.5),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: AppColors.brown,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: AppColors.brown,
    ),
    titleSmall: base.textTheme.titleSmall?.copyWith(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: AppColors.brown,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontSize: 15,
      height: 1.55,
      color: AppColors.brownSoft,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 1.55,
      color: AppColors.brownSoft,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      fontSize: 12.5,
      height: 1.5,
      color: AppColors.muted,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.muted,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: textTheme,
    canvasColor: AppColors.cream,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.brown,
      titleTextStyle: _display(size: 22, letterSpacing: -0.5),
      iconTheme: const IconThemeData(color: AppColors.brown, size: 22),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: AppColors.muted,
        fontSize: 13.5,
        height: 1.4,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.brownSoft,
        fontSize: 13.5,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.terracottaDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      prefixStyle: const TextStyle(
        color: AppColors.brownSoft,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.field),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.field),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.field),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.field),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.field),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
        disabledBackgroundColor: AppColors.beige,
        disabledForegroundColor: AppColors.muted,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brown,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.terracottaDark,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.terracotta,
      elevation: 0,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.terracottaDark : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 23,
          color: selected ? AppColors.white : AppColors.muted,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.espresso,
      disabledColor: AppColors.beigeSoft,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      labelStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.brownSoft,
      ),
      showCheckmark: false,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.espresso,
      contentTextStyle: const TextStyle(
        color: AppColors.white,
        fontSize: 13,
        height: 1.4,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: _display(size: 21, letterSpacing: -0.4),
      contentTextStyle: const TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: AppColors.brownSoft,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.borderStrong,
      dragHandleSize: Size(42, 4),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.terracotta,
      linearTrackColor: AppColors.beigeSoft,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.terracotta
            : AppColors.beige,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.espresso,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.terracotta,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.espresso,
      foregroundColor: AppColors.white,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.brownSoft,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}
