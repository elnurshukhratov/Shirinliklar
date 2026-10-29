/// customer — mijoz, staff — xodim, admin — do'kon egasi.
enum UserRole { customer, staff, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.landmark,
    required this.role,
    required this.isProfileComplete,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        landmark: json['landmark'] as String?,
        role: switch (json['role']) {
          'ADMIN' => UserRole.admin,
          'STAFF' => UserRole.staff,
          _ => UserRole.customer,
        },
        isProfileComplete: json['isProfileComplete'] == true,
      );

  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final String? landmark;
  final UserRole role;
  final bool isProfileComplete;

  /// Do'kon egasi: promokod, xodimlar, toifalar va pulni qaytarish faqat unga ochiq.
  bool get isOwner => role == UserRole.admin;

  bool get isStaff => role == UserRole.staff;

  /// Admin panelga kira oladimi (egasi yoki xodim).
  bool get isAdmin => isOwner || isStaff;

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