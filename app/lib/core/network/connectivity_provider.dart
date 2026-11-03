import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Bitta tekshiruv: haqiqiy internet yo'qligi aniq bo'lsa true.
/// Faqat DNS so'rovi sekin bo'lgani yoki server qayta ishga tushayotgani "internet yo'q" degani emas,
/// shuning uchun bu yerda faqat qurilmaning o'zi tarmoqsiz ekani yoki DNS aniq ishlamayotgani hisobga olinadi.
Future<bool> _looksOffline(Connectivity connectivity) async {
  final results = await connectivity.checkConnectivity();
  if (results.isNotEmpty && results.every((r) => r == ConnectivityResult.none)) {
    return true;
  }
  try {
    final host = Uri.parse(AppConfig.apiBaseUrl).host;
    final addrs = await InternetAddress.lookup(host).timeout(const Duration(seconds: 6));
    return addrs.isEmpty;
  } on SocketException {
    return true;
  } on TimeoutException {
    return true;
  } catch (_) {
    return false;
  }
}

/// Bitta tasodifiy xato (sekin DNS, tarmoq almashishi) butun ilovani yopib qo'ymasligi uchun
/// ketma-ket 2 marta "offline" chiqsagina offline deb hisoblanadi.
Future<bool> _checkOffline(Connectivity connectivity) async {
  if (!await _looksOffline(connectivity)) return false;
  await Future<void>.delayed(const Duration(seconds: 2));
  return _looksOffline(connectivity);
}

/// true — internet yo'q. Tarmoq o'zgarganda va har 8 soniyada qayta tekshiriladi.
/// Qo'lda qayta tekshirish uchun: ref.invalidate(isOfflineProvider).
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final trigger = StreamController<void>();
  final sub = connectivity.onConnectivityChanged.listen((_) => trigger.add(null));
  final timer = Timer.periodic(const Duration(seconds: 8), (_) => trigger.add(null));
  ref.onDispose(() {
    timer.cancel();
    sub.cancel();
    trigger.close();
  });

  trigger.add(null);
  bool? last;
  await for (final _ in trigger.stream) {
    final offline = await _checkOffline(connectivity);
    if (offline != last) {
      last = offline;
      yield offline;
    }
  }
});