import 'package:flutter/foundation.dart';

/// Admin panelga kira oladigan odam: do'kon egasi yoki xodim.
@immutable
class StaffMember {
  const StaffMember({
    required this.id,
    required this.email,
    required this.isOwner,
    required this.hasSignedIn,
    this.firstName,
    this.lastName,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        isOwner: json['role'] == 'ADMIN',
        hasSignedIn: json['hasSignedIn'] == true,
      );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isOwner;

  /// false — xodim hali Google orqali birinchi marta kirmagan.
  final bool hasSignedIn;

  String get fullName => [firstName, lastName]
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' ');

  String get initials {
    final value = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .join();
    return value.isEmpty ? email[0].toUpperCase() : value;
  }
}
