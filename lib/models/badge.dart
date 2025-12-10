class Badge {
  final int? id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? color;
  final String? category;
  final String? code;
  final String? type;
  final bool? isAutoAssignable;
  final String? awardedAt;
  final String? createdAt;
  final String? updatedAt;

  const Badge({
    this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.color,
    this.category,
    this.code,
    this.type,
    this.isAutoAssignable,
    this.awardedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as int?,
      name: json['name'] as String? ?? json['title'] as String? ?? 'Badge',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String? ?? json['icon'] as String?,
      color: json['color'] as String?,
      category: json['category'] as String?,
      code: json['code'] as String?,
      type: json['type'] as String?,
      isAutoAssignable: json['isAutoAssignable'] as bool?,
      awardedAt: json['awardedAt'] as String? ?? json['createdAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'color': color,
        'category': category,
        'code': code,
        'type': type,
        'isAutoAssignable': isAutoAssignable,
        'awardedAt': awardedAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

