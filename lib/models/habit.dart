import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String? id;
  String name;
  String? description;
  int targetDays;
  int completedDays;
  DateTime createdAt;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.targetDays,
    this.completedDays = 0,
    required this.createdAt,
  });

  factory Habit.fromMap(Map<String, dynamic> data, {String? id}) {
    final raw = data['createdAt'];

    DateTime createdAt;

    if (raw == null) {
      createdAt = DateTime.now();
    } else if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else if (raw is DateTime) {
      createdAt = raw;
    } else {
      createdAt = DateTime.now();
    }

    return Habit(
      id: id ?? data['id'],
      name: data['name'] ?? '',
      description: data['description'],
      targetDays: (data['targetDays'] is int) ? data['targetDays'] as int : int.tryParse('${data['targetDays']}') ?? 30,
      completedDays: (data['completedDays'] is int) ? data['completedDays'] as int : int.tryParse('${data['completedDays']}') ?? 0,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetDays': targetDays,
      'completedDays': completedDays,
      'createdAt': createdAt,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    int? targetDays,
    int? completedDays,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetDays: targetDays ?? this.targetDays,
      completedDays: completedDays ?? this.completedDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}