class StoreModel {
  final String? id;
  final String? tenantId;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final bool isActive;
  final DateTime? createdAt;

  StoreModel({
    this.id,
    this.tenantId,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.phone,
    this.email,
    this.logoUrl,
    this.isActive = true,
    this.createdAt,
  });

  StoreModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? address,
    String? city,
    String? state,
    String? phone,
    String? email,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
      'logo_url': logoUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      phone: json['phone'],
      email: json['email'],
      logoUrl: json['logo_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
