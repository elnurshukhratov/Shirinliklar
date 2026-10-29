import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';

/// `showModalBottomSheet` o'rniga: shisha (blur) fonli sheet. Imzo mavjud chaqiruvlar
/// bilan mos: `isScrollControlled` va `useSafeArea` doim yoqilgan.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (ctx) => _GlassSheetFrame(showDragHandle: showDragHandle, child: builder(ctx)),
  );
}

class _GlassSheetFrame extends StatelessWidget {
  const _GlassSheetFrame({required this.child, required this.showDragHandle});

  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GlassContainer(
      level: GlassLevel.sheet,
      borderRadius: AppRadius.borderSheet,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.textSecondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
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
