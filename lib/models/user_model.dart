class UserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? language;
  final String? region;
  final String? bodyType;
  final String? experienceLevel;
  final String? subscriptionTier;
  final String? role; // 'user', 'store_keeper', 'admin'
  final String? tenantId;
  final DateTime? createdAt;
  final int credits;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.language,
    this.region,
    this.bodyType,
    this.experienceLevel,
    this.subscriptionTier,
    this.role,
    this.tenantId,
    this.createdAt,
    this.credits = 0,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? language,
    String? region,
    String? bodyType,
    String? experienceLevel,
    String? subscriptionTier,
    String? role,
    String? tenantId,
    DateTime? createdAt,
    int? credits,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      region: region ?? this.region,
      bodyType: bodyType ?? this.bodyType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      credits: credits ?? this.credits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'language': language,
      'region': region,
      'body_type': bodyType,
      'experience_level': experienceLevel,
      'subscription_tier': subscriptionTier,
      'role': role,
      'tenant_id': tenantId,
      'created_at': createdAt?.toIso8601String(),
      'credits': credits,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      language: json['language'],
      region: json['region'],
      bodyType: json['body_type'],
      experienceLevel: json['experience_level'],
      subscriptionTier: json['subscription_tier'],
      role: json['role'],
      tenantId: json['tenant_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      credits: (json['credits'] as int?) ?? 0,
    );
  }
}
