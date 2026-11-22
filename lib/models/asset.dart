import 'package:flutter/foundation.dart';

enum AssetCategory {
  physical,
  digital;

  String get label {
    switch (this) {
      case AssetCategory.physical:
        return 'Physique';
      case AssetCategory.digital:
        return 'Digital';
    }
  }
}

@immutable
class Asset {
  final String id;
  final String title;
  final String description;
  final double price;
  final AssetCategory category;
  final String? imageUrl;
  final String? companyId;
  final String? missionId;

  // Physical Asset attributes
  final int? stockQuantity;
  final double? weightKg;

  // Digital Asset attributes
  final String? downloadUrl;
  final int? fileSizeBytes;
  final String? licenseType;

  final bool isAvailable;
  final DateTime createdAt;

  const Asset({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.companyId,
    this.missionId,
    this.stockQuantity,
    this.weightKg,
    this.downloadUrl,
    this.fileSizeBytes,
    this.licenseType,
    this.isAvailable = true,
    required this.createdAt,
  });

  bool get isDigital => category == AssetCategory.digital;
  bool get isPhysical => category == AssetCategory.physical;

  Asset copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    AssetCategory? category,
    String? imageUrl,
    String? companyId,
    String? missionId,
    int? stockQuantity,
    double? weightKg,
    String? downloadUrl,
    int? fileSizeBytes,
    String? licenseType,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Asset(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      companyId: companyId ?? this.companyId,
      missionId: missionId ?? this.missionId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      weightKg: weightKg ?? this.weightKg,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      licenseType: licenseType ?? this.licenseType,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category.name,
      'imageUrl': imageUrl,
      'companyId': companyId,
      'missionId': missionId,
      'stockQuantity': stockQuantity,
      'weightKg': weightKg,
      'downloadUrl': downloadUrl,
      'fileSizeBytes': fileSizeBytes,
      'licenseType': licenseType,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: AssetCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AssetCategory.physical,
      ),
      imageUrl: json['imageUrl'] as String?,
      companyId: json['companyId'] as String?,
      missionId: json['missionId'] as String?,
      stockQuantity: json['stockQuantity'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      downloadUrl: json['downloadUrl'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      licenseType: json['licenseType'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
