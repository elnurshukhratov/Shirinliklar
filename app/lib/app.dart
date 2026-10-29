import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_provider.dart';
import 'core/network/connectivity_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/notifications/application/push_service.dart';
import 'l10n/gen/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final reduceMotion = View.of(context).platformDispatcher.accessibilityFeatures.disableAnimations;

    // Kirib, ma'lumotlar to'ldirilgach bildirishnomalar yoqiladi.
    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.signedIn && (next.user?.isProfileComplete ?? false)) {
        ref.read(pushServiceProvider).start();
      }
    });
    // Til o'zgarsa, bildirishnomalar ham yangi tilda keladi.
    ref.listen(localeProvider, (_, __) => ref.read(pushServiceProvider).sync());

    // Internet yo'qolsa, ekranda doimiy ogohlantirish chiqadi; qaytsa, yo'qoladi.
    ref.listen<AsyncValue<bool>>(isOfflineProvider, (prev, next) {
      final offline = next.valueOrNull ?? false;
      final wasOffline = prev?.valueOrNull ?? false;
      void apply() {
        final messenger = scaffoldMessengerKey.currentState;
        if (messenger == null) return;
        final l10n = lookupAppLocalizations(locale);
        if (offline) {
          messenger
            ..hideCurrentMaterialBanner()
            ..showMaterialBanner(MaterialBanner(
              leading: const Icon(Icons.wifi_off_rounded),
              content: Text(l10n.offlineBanner),
              actions: [
                TextButton(onPressed: messenger.hideCurrentMaterialBanner, child: Text(l10n.commonClose)),
              ],
            ));
        } else {
          messenger.hideCurrentMaterialBanner();
          if (wasOffline) {
            messenger.showSnackBar(SnackBar(
              content: Text(l10n.offlineBackOnline),
              duration: const Duration(seconds: 2),
            ));
          }
        }
      }

      if (scaffoldMessengerKey.currentState == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => apply());
      } else {
        apply();
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      themeAnimationDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeOut,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
