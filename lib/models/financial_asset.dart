import 'package:flutter/foundation.dart';

enum FinancialAssetCategory {
  pmeEquity,
  physicalAssetToken,
  digitalAssetToken,
  bonds;

  String get label {
    switch (this) {
      case FinancialAssetCategory.pmeEquity:
        return 'Actions PME';
      case FinancialAssetCategory.physicalAssetToken:
        return 'Actif Physique Tokenisé';
      case FinancialAssetCategory.digitalAssetToken:
        return 'Projet Digital Tokenisé';
      case FinancialAssetCategory.bonds:
        return 'Obligation / Dette';
    }
  }
}

@immutable
class FinancialAsset {
  final String id;
  final String symbol;
  final String companyId;
  final String companyName;
  final String title;
  final String description;
  final double sharePrice;
  final double previousPrice;
  final int totalShares;
  final int availableShares;
  final double expectedAnnualYield;
  final FinancialAssetCategory category;
  final List<double> priceHistory;
  final DateTime createdAt;

  const FinancialAsset({
    required this.id,
    required this.symbol,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.sharePrice,
    required this.previousPrice,
    required this.totalShares,
    required this.availableShares,
    required this.expectedAnnualYield,
    required this.category,
    required this.priceHistory,
    required this.createdAt,
  });

  double get priceChangePercent {
    if (previousPrice <= 0) return 0.0;
    return ((sharePrice - previousPrice) / previousPrice) * 100;
  }

  bool get isUp => sharePrice >= previousPrice;

  FinancialAsset copyWith({
    String? id,
    String? symbol,
    String? companyId,
    String? companyName,
    String? title,
    String? description,
    double? sharePrice,
    double? previousPrice,
    int? totalShares,
    int? availableShares,
    double? expectedAnnualYield,
    FinancialAssetCategory? category,
    List<double>? priceHistory,
    DateTime? createdAt,
  }) {
    return FinancialAsset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      description: description ?? this.description,
      sharePrice: sharePrice ?? this.sharePrice,
      previousPrice: previousPrice ?? this.previousPrice,
      totalShares: totalShares ?? this.totalShares,
      availableShares: availableShares ?? this.availableShares,
      expectedAnnualYield: expectedAnnualYield ?? this.expectedAnnualYield,
      category: category ?? this.category,
      priceHistory: priceHistory ?? this.priceHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'description': description,
      'sharePrice': sharePrice,
      'previousPrice': previousPrice,
      'totalShares': totalShares,
      'availableShares': availableShares,
      'expectedAnnualYield': expectedAnnualYield,
      'category': category.name,
      'priceHistory': priceHistory,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialAsset.fromJson(Map<String, dynamic> json) {
    return FinancialAsset(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sharePrice: (json['sharePrice'] as num).toDouble(),
      previousPrice: (json['previousPrice'] as num).toDouble(),
      totalShares: json['totalShares'] as int,
      availableShares: json['availableShares'] as int,
      expectedAnnualYield: (json['expectedAnnualYield'] as num).toDouble(),
      category: FinancialAssetCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FinancialAssetCategory.pmeEquity,
      ),
      priceHistory: (json['priceHistory'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
