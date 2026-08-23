class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String createdAt;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.createdAt,
  });

  // Convert database data → Customer object
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  // Convert Customer object → database data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt,
    };
  }
}
