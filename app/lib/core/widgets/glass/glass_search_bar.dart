import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';

/// Pilyulasimon shisha qidiruv paneli. Matn kiritish va tozalash tugmasi bilan.
/// [focusNode] berilsa, fokusni tashqaridan boshqarish mumkin (masalan, qidiruv sahifasi ochilganda).
class GlassSearchBar extends StatefulWidget {
  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.blur = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool blur;
  final FocusNode? focusNode;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  bool get _ownsFocus => widget.focusNode == null;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
    _focus.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.removeListener(_onText);
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    // Fokusda: olcha rangli yupqa halqa va mayin yorug'lik (shisha "yonadi").
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.fast),
      curve: AppMotion.curve,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderPill,
        boxShadow: _focus.hasFocus
            ? [BoxShadow(color: c.cta.withValues(alpha: 0.28), blurRadius: 18, spreadRadius: 1)]
            : const [],
      ),
      child: GlassContainer(
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
                  focusNode: _focus,
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
      ),
    );
  }
}