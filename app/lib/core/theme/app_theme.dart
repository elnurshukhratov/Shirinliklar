import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = AppTypography.textTheme(c);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.textPrimary,
      error: c.error,
      onError: brightness == Brightness.dark ? c.background : Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      outline: c.border,
    );

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      // Fon app.dart builder'idagi yagona AmbientBackground; sahifalar shaffof.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: c.background,
      textTheme: textTheme,
      dividerColor: c.border,
      // Yumshoq, past kontrastli to'lqin (yorqin "sparkle" emas); asosiy tugmalarda o'z jelly effekti bor.
      splashFactory: InkRipple.splashFactory,
      splashColor: c.primary.withValues(alpha: 0.10),
      highlightColor: c.primary.withValues(alpha: 0.05),
      hoverColor: c.primary.withValues(alpha: 0.04),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SoftPageTransitionsBuilder(),
          TargetPlatform.iOS: SoftPageTransitionsBuilder(),
          TargetPlatform.linux: SoftPageTransitionsBuilder(),
          TargetPlatform.macOS: SoftPageTransitionsBuilder(),
          TargetPlatform.windows: SoftPageTransitionsBuilder(),
          TargetPlatform.fuchsia: SoftPageTransitionsBuilder(),
        },
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.28),
        selectionHandleColor: c.primary,
      ),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle:
            brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textSecondary.withValues(alpha: 0.8)),
        errorStyle: TextStyle(color: c.error),
        border: border(c.border),
        enabledBorder: border(c.border),
        disabledBorder: border(c.border),
        focusedBorder: border(c.primary, 1.8),
        errorBorder: border(c.error),
        focusedErrorBorder: border(c.error, 1.5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.background),
        actionTextColor: brightness == Brightness.dark ? c.cta : c.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
        insetPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: c.border),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSheet),
        showDragHandle: true,
        dragHandleColor: c.textSecondary.withValues(alpha: 0.5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: c.shadowStrong,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderCard,
          side: BorderSide(color: c.border),
        ),
        textStyle: textTheme.bodyLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: c.cta.withValues(alpha: 0.22),
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? c.primary : c.textSecondary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.cta,
        foregroundColor: c.onCta,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
        circularTrackColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.cta : c.border,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.cta : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onCta),
        side: BorderSide(color: c.textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.cta : c.textSecondary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.cta,
        inactiveTrackColor: c.border,
        thumbColor: c.cta,
      ),
    );
  }
}


/// Sahifa o'tishi (Navigator ishlatiladigan marshrutlar uchun): eski sahifa tez so'nadi,
/// yangisi ozgina pastdan ko'tarilib paydo bo'ladi — shaffof sahifalarning matni
/// bir-birining ustida ko'rinib qolmaydi.
class SoftPageTransitionsBuilder extends PageTransitionsBuilder {
  const SoftPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) return child;
    final enter = CurvedAnimation(parent: animation, curve: AppMotion.smoothCurve);
    final fadeIn = CurvedAnimation(parent: animation, curve: const Interval(0.4, 1.0));
    final fadeOut = CurvedAnimation(parent: secondaryAnimation, curve: const Interval(0.0, 0.4));
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(fadeOut),
      child: FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(enter),
          child: child,
        ),
      ),
    );
  }
}