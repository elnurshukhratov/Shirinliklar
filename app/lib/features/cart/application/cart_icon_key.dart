import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dock'dagi savat ikonkasining GlobalKey'i. 3-bosqichdagi "savatga uchish" animatsiyasi
/// ikonka o'rnini (RenderBox) shu kalit orqali topadi. Kalit faqat dock'dagi BITTA ikonkada ishlatiladi.
final cartIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey(debugLabel: 'dockCartIcon'));