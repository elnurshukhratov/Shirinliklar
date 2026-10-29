import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';
import '../../auth/application/auth_controller.dart';
import '../data/device_repository.dart';

/// Ilova ochiq paytida kelgan bildirishnomani ko'rsatish uchun.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Push (FCM): ruxsat so'rash, qurilma tokenini serverda saqlash/yangilash va bildirishnoma bosilganda kerakli ekranni ochish.
class PushService {
  PushService(this._ref);

  final Ref _ref;
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  bool _started = false;
  String? _token;
  final _subs = <StreamSubscription<dynamic>>[];

  DeviceRepository get _repo => DeviceRepository(_ref.read(apiClientProvider));

  /// Kirishdan keyin bir marta chaqiriladi.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await requestPermission();
      await _sync();

      _subs.add(_fcm.onTokenRefresh.listen((t) {
        _token = t;
        unawaited(_sync());
      }));
      _subs.add(FirebaseMessaging.onMessage.listen(_onForeground));
      _subs.add(FirebaseMessaging.onMessageOpenedApp.listen(_open));

      final initial = await _fcm.getInitialMessage();
      if (initial != null) _open(initial);
    } catch (e) {
      // Bildirishnoma ishlamasa ham ilova ishlashda davom etadi.
      debugPrint('Push ishga tushmadi: $e');
    }
  }

  /// Tizim ruxsat oynasini ko'rsatadi (Android 13+ va iOS). Ruxsat berilgan bo'lsa true.
  Future<bool> requestPermission() async {
    try {
      final settings = await _fcm.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Token va joriy til serverga yuboriladi (til o'zgarganda ham chaqiriladi).
  Future<void> sync() async {
    if (!_started) return;
    await _sync();
  }

  Future<void> _sync() async {
    try {
      final token = _token ??= await _fcm.getToken();
      if (token == null || token.isEmpty) return;
      await _repo.register(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
        language: _ref.read(localeProvider).languageCode,
      );
    } catch (e) {
      debugPrint("Qurilma tokenini saqlab bo'lmadi: $e");
    }
  }

  /// Chiqishdan oldin chaqiriladi: bu qurilmaga endi xabar kelmaydi.
  Future<void> unregister() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _started = false;
    try {
      final token = _token ?? await _fcm.getToken();
      if (token != null && token.isNotEmpty) await _repo.unregister(token);
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint("Qurilmani o'chirib bo'lmadi: $e");
    }
    _token = null;
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    final messenger = scaffoldMessengerKey.currentState;
    if (n == null || messenger == null) return;
    final title = n.title ?? '';
    final body = n.body ?? '';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(body.isEmpty ? title : '$title\n$body'),
        duration: const Duration(seconds: 5),
        action: _routeOf(message) == null
            ? null
            : SnackBarAction(label: '→', onPressed: () => _open(message)),
      ));
  }

  /// Bildirishnoma turiga qarab ochiladigan ekran.
  String? _routeOf(RemoteMessage message) {
    final data = message.data;
    switch (data['type']) {
      case 'ORDER_STATUS':
        final id = data['orderId'];
        return id == null ? null : AppRoutes.myOrder(id);
      case 'NEW_ORDER':
        final id = data['orderId'];
        return id == null ? null : AppRoutes.adminOrder(id);
      case 'BACK_IN_STOCK':
        final id = data['productId'];
        return id == null ? null : AppRoutes.product(id);
    }
    return null;
  }

  void _open(RemoteMessage message) {
    final route = _routeOf(message);
    if (route == null) return;
    if (_ref.read(authControllerProvider).user == null) return;
    _ref.read(appRouterProvider).push(route);
  }
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));
