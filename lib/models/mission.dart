import 'package:flutter/foundation.dart';

enum MissionStatus {
  draft,
  pending,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case MissionStatus.draft:
        return 'Brouillon';
      case MissionStatus.pending:
        return 'En attente';
      case MissionStatus.inProgress:
        return 'En cours';
      case MissionStatus.completed:
        return 'Terminée';
      case MissionStatus.cancelled:
        return 'Annulée';
    }
  }
}

@immutable
class Mission {
  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String description;
  final String objective;
  final double budget;
  final MissionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> assetIds;
  final DateTime createdAt;

  const Mission({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.objective,
    required this.budget,
    this.status = MissionStatus.draft,
    required this.startDate,
    required this.endDate,
    this.assetIds = const [],
    required this.createdAt,
  });

  Mission copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? title,
    String? description,
    String? objective,
    double? budget,
    MissionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? assetIds,
    DateTime? createdAt,
  }) {
    return Mission(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      assetIds: assetIds ?? this.assetIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'description': description,
      'objective': objective,
      'budget': budget,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'assetIds': assetIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      objective: json['objective'] as String,
      budget: (json['budget'] as num).toDouble(),
      status: MissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MissionStatus.draft,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      assetIds: (json['assetIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
