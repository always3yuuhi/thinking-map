class DiaryEntry {
  final int? id;
  final DateTime date;
  final String body;
  final bool manuallyEdited;
  final DateTime updatedAt;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.body,
    this.manuallyEdited = false,
    required this.updatedAt,
  });

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DiaryEntry copyWith({
    int? id,
    DateTime? date,
    String? body,
    bool? manuallyEdited,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      body: body ?? this.body,
      manuallyEdited: manuallyEdited ?? this.manuallyEdited,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': dateOnly(date).toIso8601String(),
      'body': body,
      'manually_edited': manuallyEdited ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, Object?> map) {
    return DiaryEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      body: map['body'] as String,
      manuallyEdited: (map['manually_edited'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
