import 'package:flutter/foundation.dart';

@immutable
class Company {
  final String id;
  final String name;
  final String? logoUrl;
  final String email;
  final String? phone;
  final String? sector;
  final String? description;
  final String? website;
  final DateTime createdAt;

  const Company({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.email,
    this.phone,
    this.sector,
    this.description,
    this.website,
    required this.createdAt,
  });

  Company copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? email,
    String? phone,
    String? sector,
    String? description,
    String? website,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sector: sector ?? this.sector,
      description: description ?? this.description,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'email': email,
      'phone': phone,
      'sector': sector,
      'description': description,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      sector: json['sector'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.logoUrl == logoUrl &&
        other.email == email &&
        other.phone == phone &&
        other.sector == sector &&
        other.description == description &&
        other.website == website &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        logoUrl.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        sector.hashCode ^
        description.hashCode ^
        website.hashCode ^
        createdAt.hashCode;
  }
}
