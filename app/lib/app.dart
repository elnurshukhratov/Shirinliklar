import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_motion.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/widgets/glass/ambient_background.dart';
import 'core/widgets/offline_gate.dart';
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

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      // Jonli fon BITTA joyda; sahifalar (Scaffold) shaffof.
      builder: (context, child) => AmbientBackground(
        child: OfflineGate(child: child ?? const SizedBox.shrink()),
      ),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      themeAnimationDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
      themeAnimationCurve: AppMotion.smoothCurve,
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