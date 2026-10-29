import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';

/// Pilyulasimon shisha qidiruv paneli. Matn kiritish va tozalash tugmasi bilan.
class GlassSearchBar extends StatefulWidget {
  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.blur = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool blur;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return GlassContainer(
      level: GlassLevel.floating,
      blur: widget.blur,
      borderRadius: AppRadius.borderPill,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Icon(Icons.search_rounded, color: c.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                style: text.bodyLarge,
                cursorColor: c.primary,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: text.bodyLarge?.copyWith(color: c.textSecondary),
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                icon: Icon(Icons.close_rounded, color: c.textSecondary, size: 20),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
              )
            else
              const SizedBox(width: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
