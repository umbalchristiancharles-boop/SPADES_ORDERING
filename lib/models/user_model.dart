// ============================================================================
// USER MODEL
// ============================================================================

class UserModel {
  final String email;
  final String name;
  final String phone;
  final String address;

  UserModel({
    required this.email,
    this.name = 'John Doe',
    this.phone = '+1 234 567 8900',
    this.address = '123 Main Street',
  });

  UserModel copyWith({
    String? email,
    String? name,
    String? phone,
    String? address,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

