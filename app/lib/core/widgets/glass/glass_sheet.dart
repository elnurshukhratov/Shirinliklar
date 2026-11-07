import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';

/// `showModalBottomSheet` o'rniga: shisha (panel) bottom sheet. Yuqori burchaklar 28 radiusli,
/// orqa fon blur + to'yinganlik bilan "suyuq shisha" ko'rinishida. Ichki kontent klaviatura
/// bo'shlig'ini (viewInsets) o'zi hisobga oladi.
///
/// Sheet ochilish/yopilishi Material'ning prujinasimon sheet harakatida; "harakatni kamaytirish"
/// yoqilgan bo'lsa, tizim animatsiyasi o'chiriladi.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool showDragHandle = false,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    useSafeArea: useSafeArea,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => GlassSheetSurface(showDragHandle: showDragHandle, child: builder(ctx)),
  );
}

/// [showGlassSheet] ichidagi shisha sirt. Alohida ishlatilishi ham mumkin.
class GlassSheetSurface extends StatelessWidget {
  const GlassSheetSurface({super.key, required this.child, this.showDragHandle = false});

  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const radius = BorderRadius.vertical(top: Radius.circular(AppRadius.panel));

    return GlassContainer(
      level: GlassLevel.panel,
      borderRadius: radius,
      overMedia: true,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.textSecondary.withValues(alpha: 0.45),
                    borderRadius: AppRadius.borderPill,
                  ),
                ),
              ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}