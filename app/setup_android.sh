#!/usr/bin/env bash
# Yetishmayotgan Android fayllarini (gradle wrapper, settings.gradle.kts va h.k.) yaratadi,
# bizning sozlangan fayllarimizni esa joyida saqlaydi. Bir marta ishga tushiriladi.
set -euo pipefail
cd "$(dirname "$0")"

backup="$(mktemp -d)"
cp -r android lib pubspec.yaml "$backup"/

flutter create . --platforms=android --org uz.shirinliklar --project-name shirinliklar

# flutter create noto'g'ri paketli MainActivity va keraksiz test yaratadi
rm -rf android/app/src/main/kotlin test/widget_test.dart

# bizning fayllarni qaytarish
cp -r "$backup"/android/. android/
cp -r "$backup"/lib/. lib/
cp "$backup"/pubspec.yaml pubspec.yaml

flutter pub get
flutter gen-l10n
echo "Tayyor. Endi: cp env.example.json env.json  (to'ldiring), keyin: flutter run --dart-define-from-file=env.json"
