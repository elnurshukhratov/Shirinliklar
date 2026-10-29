/// Ro'yxatning keyingi sahifasi yuklanmay qolsa (masalan, tarmoq uzilsa), ro'yxat tugagan deb
/// hisoblanmaydi: foydalanuvchi qayta surganda yana urinib ko'riladi, lekin har surishda emas.
class LoadMoreCooldown {
  static const Duration _wait = Duration(seconds: 2);

  DateTime? _failedAt;

  bool get active => _failedAt != null && DateTime.now().difference(_failedAt!) < _wait;

  void fail() => _failedAt = DateTime.now();
}
