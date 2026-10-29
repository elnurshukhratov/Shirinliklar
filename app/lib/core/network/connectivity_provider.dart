import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _isOffline(List<ConnectivityResult> results) =>
    results.isNotEmpty && results.every((r) => r == ConnectivityResult.none);

/// true — qurilmada hech qanday tarmoq yo'q. Holat o'zgarganda yangilanadi.
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _isOffline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOffline).distinct();
});
