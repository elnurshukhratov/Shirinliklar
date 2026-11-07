import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Harakat tizimi: asosan **prujina (spring)** fizikasi, davomiyliklar esa faqat
/// prujina ishlatib bo'lmaydigan joylar (Opacity, TweenAnimationBuilder) uchun qoldirilgan.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);

  /// Element kirishi (Reveal), dialog va sheet uchun.
  static const Duration entrance = Duration(milliseconds: 420);

  /// Sahifa o'tishi.
  static const Duration page = Duration(milliseconds: 380);

  /// Ketma-ket (stagger) elementlar orasidagi kechikish va eng ko'p qadam soni.
  static const Duration stagger = Duration(milliseconds: 55);
  static const int maxStaggerSteps = 7;

  // ---- Prujinalar -----------------------------------------------------------

  /// Tugma va chip: tez, deyarli sakramaydi.
  static const SpringDescription snappy =
      SpringDescription(mass: 1, stiffness: 500, damping: 30);

  /// Karta va sahifa: yumshoq, sakramaydi.
  static const SpringDescription smooth =
      SpringDescription(mass: 1, stiffness: 260, damping: 28);

  /// Badge va indikator: sezilarli sakrash (squash & stretch).
  static const SpringDescription bouncy =
      SpringDescription(mass: 1, stiffness: 380, damping: 17);

  /// [desc] prujinasi bilan [from] dan [to] gacha harakatlanadigan simulyatsiya.
  /// `AnimationController.animateWith` bilan ishlatiladi (controller 0..1 oralig'ida
  /// chegaralanmasligi uchun `unbounded` bo'lishi mumkin).
  static SpringSimulation spring({
    SpringDescription desc = smooth,
    double from = 0,
    double to = 1,
    double velocity = 0,
  }) =>
      SpringSimulation(desc, from, to, velocity, tolerance: const Tolerance(distance: 0.001, velocity: 0.01));

  // ---- Implicit animatsiyalar uchun egri chiziqlar (hammasi prujinadan) ----
  // Nomlar saqlangan: ularni ishlatadigan fayllar buzilmasin.

  // Cubic egri chiziqlar olib tashlangan: eski nomlar endi "smooth" prujinasini beradi.
  static const Curve curve = SpringCurve(smooth);
  static const Curve emphasized = SpringCurve(smooth);

  /// Implicit animatsiyalar (AnimatedContainer va h.k.) uchun prujina egri chizig'i.
  /// Eski `AppMotion.spring` Curve'i shu nomga o'tgan: `spring(...)` endi simulyatsiya yaratadi.
  static const Curve springCurve = SpringCurve(bouncy);
  static const Curve snappyCurve = SpringCurve(snappy);
  static const Curve smoothCurve = SpringCurve(smooth);

  /// Qurilmada "harakatni kamaytirish" yoqilganmi.
  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// Harakat kamaytirilgan bo'lsa nol, aks holda berilgan davomiylik.
  static Duration of(BuildContext context, [Duration d = normal]) =>
      reduced(context) ? Duration.zero : d;
}

/// Prujina simulyatsiyasidan olingan [Curve]: 0 dan 1 gacha, oxirida aniq 1.
/// Sakraydigan prujinalarda qiymat 1 dan oshib ketishi mumkin (shu uning ma'nosi).
class SpringCurve extends Curve {
  const SpringCurve(this.description);

  final SpringDescription description;

  /// Simulyatsiya o'zgarmas (faqat x(t) o'qiladi): har kadrda qayta yaratilmasligi uchun keshlanadi.
  static final Map<SpringDescription, SpringSimulation> _cache = {};

  @override
  double transformInternal(double t) {
    final sim = _cache.putIfAbsent(description, () => SpringSimulation(description, 0, 1, 0));
    // t in 0..1 ni prujinaning joylashish vaqtiga (~0.7 s) cho'zamiz;
    // oxirgi 10% da qiymat aniq 1 ga silliq tortiladi.
    const settle = 0.7;
    const tail = 0.9;
    final x = sim.x(t * settle);
    if (t <= tail) return x;
    return x + (1 - x) * ((t - tail) / (1 - tail));
  }
}

/// `AnimationController.animateWith` ustiga qulay qatlam.
extension SpringController on AnimationController {
  /// Controller qiymatini joriy qiymatdan [target] ga prujina bilan olib boradi.
  /// Boshlang'ich tezlik saqlanadi, shuning uchun uzilgan animatsiya silliq davom etadi.
  TickerFuture springTo(
    double target, {
    SpringDescription description = AppMotion.smooth,
  }) {
    return animateWith(
      AppMotion.spring(desc: description, from: value, to: target, velocity: velocity),
    );
  }
}

/// [value] o'zgarganda uni prujina bilan animatsiyalaydigan vidjet.
/// "Harakatni kamaytirish" yoqilgan bo'lsa qiymat darhol o'rnatiladi.
class SpringBuilder extends StatefulWidget {
  const SpringBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.description = AppMotion.smooth,
    this.child,
  });

  final double value;
  final SpringDescription description;
  final Widget? child;
  final Widget Function(BuildContext context, double value, Widget? child) builder;

  @override
  State<SpringBuilder> createState() => _SpringBuilderState();
}

class _SpringBuilderState extends State<SpringBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(vsync: this, value: widget.value);

  @override
  void didUpdateWidget(SpringBuilder old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    if (AppMotion.reduced(context)) {
      _c.value = widget.value;
    } else {
      _c.springTo(widget.value, description: widget.description);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) => widget.builder(context, _c.value, child),
      );
}