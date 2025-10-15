class Detection {
  final String id;
  final bool isStroke;
  final double confidencePercent;
  final DateTime createdAt;
  final String? note;

  Detection({
    required this.id,
    required this.isStroke,
    required this.confidencePercent,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'isStroke': isStroke,
      'confidencePercent': confidencePercent,
      'createdAt': createdAt.toUtc(),
      'note': note,
    };
  }

  factory Detection.fromMap(String id, Map<String, dynamic> data) {
    return Detection(
      id: id,
      isStroke: (data['isStroke'] as bool?) ?? false,
      confidencePercent: (data['confidencePercent'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] is DateTime)
          ? data['createdAt'] as DateTime
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      note: data['note'] as String?,
    );
  }
}


