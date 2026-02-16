class DesignPatternModel {
  final String? id;
  final String? tenantId;
  final String? storeId;
  final String name;
  final String? description;
  final String? borderImageUrl;
  final String? palluImageUrl;
  final String? pleatsImageUrl;
  final String? combinedImageUrl;
  final String? category;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DesignPatternModel({
    this.id,
    this.tenantId,
    this.storeId,
    required this.name,
    this.description,
    this.borderImageUrl,
    this.palluImageUrl,
    this.pleatsImageUrl,
    this.combinedImageUrl,
    this.category,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  DesignPatternModel copyWith({
    String? id,
    String? tenantId,
    String? storeId,
    String? name,
    String? description,
    String? borderImageUrl,
    String? palluImageUrl,
    String? pleatsImageUrl,
    String? combinedImageUrl,
    String? category,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DesignPatternModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      borderImageUrl: borderImageUrl ?? this.borderImageUrl,
      palluImageUrl: palluImageUrl ?? this.palluImageUrl,
      pleatsImageUrl: pleatsImageUrl ?? this.pleatsImageUrl,
      combinedImageUrl: combinedImageUrl ?? this.combinedImageUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'store_id': storeId,
      'name': name,
      'description': description,
      'border_image_url': borderImageUrl,
      'pallu_image_url': palluImageUrl,
      'pleats_image_url': pleatsImageUrl,
      'combined_image_url': combinedImageUrl,
      'category': category,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory DesignPatternModel.fromJson(Map<String, dynamic> json) {
    return DesignPatternModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      storeId: json['store_id'],
      name: json['name'] ?? '',
      description: json['description'],
      borderImageUrl: json['border_image_url'],
      palluImageUrl: json['pallu_image_url'],
      pleatsImageUrl: json['pleats_image_url'],
      combinedImageUrl: json['combined_image_url'],
      category: json['category'],
      price: json['price']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
