import 'package:flutter/material.dart';
import '../../../../core/widgets/glass/glass_dialog.dart';


Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  return showGlassConfirm(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
  );
}