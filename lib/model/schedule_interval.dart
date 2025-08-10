enum ScheduleType { cycling, work, other }

String scheduleTypeToString(ScheduleType t) {
  switch (t) {
    case ScheduleType.cycling: return 'Cycling';
    case ScheduleType.work:    return 'Work';
    case ScheduleType.other:   return 'Other';
  }
}

ScheduleType scheduleTypeFromString(String s) {
  switch (s) {
    case 'Cycling': return ScheduleType.cycling;
    case 'Work':    return ScheduleType.work;
    case 'Other':   return ScheduleType.other;
    default: throw ArgumentError('Unknown ScheduleType: $s');
  }
}

class ScheduleInterval {
  final String? id;        // <- optional for “create”
  final String userId;
  ScheduleType type;
  DateTime start;    // tz-aware ISO-8601
  DateTime end;
  String? title;
  String? description;

  ScheduleInterval({
    this.id,
    required this.userId,
    required this.type,
    required this.start,
    required this.end,
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'p_user_id': userId,
    'p_type':    scheduleTypeToString(type),
    'p_start':   start.toIso8601String(),
    'p_end':     end.toIso8601String(),
    'p_title':   title,
    'p_description': description
  };

  // Parse row returned by RPC (which returns the inserted row)
  factory ScheduleInterval.fromJson(Map<String, dynamic> j) => ScheduleInterval(
    id: j['id'] as String?,
    userId: j['user_id'] as String,
    type: scheduleTypeFromString(j['type'] as String),
    start: DateTime.parse(j['start_at'] as String),
    end: DateTime.parse(j['end_at'] as String),
    title: j['title'] as String?,
    description: j['description'] as String?,
  );

  @override
  String toString() {
    return 'ScheduleInterval(id: $id, userId: $userId, type: $type, start: $start, end: $end, title: $title, description: $description)';
  }
}
