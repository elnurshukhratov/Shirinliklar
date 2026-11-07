import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n_extensions.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';
import 'pressable.dart';

/// `showDialog` o'rniga: shisha dialog. Fon xiralashadi, dialog markazdan yumshoq kattalashib chiqadi.
/// "Harakatni kamaytirish" yoqilgan bo'lsa, animatsiyasiz ochiladi.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: AppMotion.of(context, const Duration(milliseconds: 280)),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (ctx, animation, _, child) {
      if (AppMotion.reduced(ctx)) return child;
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.emphasized);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Tasdiqlash dialogi: `true` — tasdiqlandi, `false` — bekor qilindi (yoki tashqariga bosildi).
/// [destructive] bo'lsa, tasdiqlash tugmasi xato (qizil) tusda bo'ladi.
Future<bool> showGlassConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = true,
}) async {
  final result = await showGlassDialog<bool>(
    context: context,
    builder: (ctx) => GlassDialog(
      title: title,
      message: message,
      actions: [
        GlassDialogAction(
          label: confirmLabel,
          kind: destructive ? GlassDialogActionKind.destructive : GlassDialogActionKind.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        GlassDialogAction(
          label: cancelLabel ?? ctx.l10n.commonCancel,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    ),
  );
  return result == true;
}

/// Shisha dialog ramkasi: sarlavha, matn yoki ixtiyoriy [content] va ustma-ust turgan tugmalar
/// (uzun rus/ingliz matnlarida ham sig'adi). Klaviatura chiqqanda yuqoriga suriladi.
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.actions,
  });

  final String title;
  final String? message;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: AppMotion.of(context, AppMotion.fast),
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        bottom: keyboard == 0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: GlassContainer(
                level: GlassLevel.panel,
                overMedia: true,
                borderRadius: AppRadius.borderPanel,
                child: Material(
                  type: MaterialType.transparency,
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    explicitChildNodes: true,
                    label: title,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(title, textAlign: TextAlign.center, style: text.titleLarge),
                                  if (message != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      message!,
                                      textAlign: TextAlign.center,
                                      style: text.bodyMedium?.copyWith(color: c.textSecondary),
                                    ),
                                  ],
                                  if (content != null) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    content!,
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            actions[i],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum GlassDialogActionKind { primary, destructive, neutral }

/// Dialog tugmasi: primary — olcha, destructive — qizil, neutral — yupqa shaffof.
/// [onPressed] `null` bo'lsa, tugma o'chiq ko'rinadi.
class GlassDialogAction extends StatelessWidget {
  const GlassDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = GlassDialogActionKind.neutral,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlassDialogActionKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null;

    final Color? fill = switch (kind) {
      GlassDialogActionKind.primary => c.cta,
      GlassDialogActionKind.destructive => dark ? c.error.withValues(alpha: 0.22) : c.error,
      GlassDialogActionKind.neutral => null,
    };
    final Color fg = switch (kind) {
      GlassDialogActionKind.primary => c.onCta,
      GlassDialogActionKind.destructive => dark ? c.error : Colors.white,
      GlassDialogActionKind.neutral => c.textPrimary,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: AppMotion.of(context, AppMotion.fast),
        opacity: enabled ? 1 : 0.45,
        child: Pressable(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill ?? c.textPrimary.withValues(alpha: dark ? 0.10 : 0.06),
              borderRadius: AppRadius.borderPill,
              border: Border.all(
                color: Colors.white.withValues(alpha: fill == null ? (dark ? 0.12 : 0.5) : 0.22),
              ),
            ),
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}