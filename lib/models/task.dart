import 'package:flutter/foundation.dart';

enum TaskStatus {
  todo,
  inProgress,
  underReview,
  completed,
  rejected;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.underReview:
        return 'En révision';
      case TaskStatus.completed:
        return 'Terminée';
      case TaskStatus.rejected:
        return 'Rejetée';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }
}

@immutable
class Task {
  final String id;
  final String missionId;
  final String title;
  final String description;
  final String? assignedToUserId;
  final String? assignedToUserName;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? proofOfWorkUrl;
  final String? proofNotes;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.missionId,
    required this.title,
    required this.description,
    this.assignedToUserId,
    this.assignedToUserName,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    required this.dueDate,
    this.proofOfWorkUrl,
    this.proofNotes,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? missionId,
    String? title,
    String? description,
    String? assignedToUserId,
    String? assignedToUserName,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? proofOfWorkUrl,
    String? proofNotes,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      proofOfWorkUrl: proofOfWorkUrl ?? this.proofOfWorkUrl,
      proofNotes: proofNotes ?? this.proofNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'missionId': missionId,
      'title': title,
      'description': description,
      'assignedToUserId': assignedToUserId,
      'assignedToUserName': assignedToUserName,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'proofOfWorkUrl': proofOfWorkUrl,
      'proofNotes': proofNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      missionId: json['missionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedToUserId: json['assignedToUserId'] as String?,
      assignedToUserName: json['assignedToUserName'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      proofOfWorkUrl: json['proofOfWorkUrl'] as String?,
      proofNotes: json['proofNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
