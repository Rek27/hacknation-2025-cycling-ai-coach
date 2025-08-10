import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathon/model/schedule_interval.dart';

final String userId = '00000000-0000-0000-0000-000000000000';

final mockIntervals = <ScheduleInterval>[
  // -------- Mon 2025-08-11 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-11T07:15:00+02:00'),
    end:   DateTime.parse('2025-08-11T08:00:00+02:00'),
    title: 'Easy spin',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-11T09:00:00+02:00'),
    end:   DateTime.parse('2025-08-11T12:00:00+02:00'),
    title: 'Sprint planning',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-11T12:15:00+02:00'),
    end:   DateTime.parse('2025-08-11T13:00:00+02:00'),
    title: 'Lunch',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-11T15:00:00+02:00'),
    end:   DateTime.parse('2025-08-11T16:30:00+02:00'),
    title: '1:1s + code review',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-11T18:00:00+02:00'),
    end:   DateTime.parse('2025-08-11T19:30:00+02:00'),
    title: 'After-work ride',
  ),

  // -------- Tue 2025-08-12 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-12T09:00:00+02:00'),
    end:   DateTime.parse('2025-08-12T10:30:00+02:00'),
    title: 'Team sync',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-12T10:15:00+02:00'),
    end:   DateTime.parse('2025-08-12T11:00:00+02:00'),
    title: 'Commute ride', // overlaps Work
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-12T14:15:00+02:00'),
    end:   DateTime.parse('2025-08-12T17:00:00+02:00'),
    title: 'Feature implementation',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-12T13:00:00+02:00'),
    end:   DateTime.parse('2025-08-12T14:15:00+02:00'),
    title: 'Groceries',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-12T17:15:00+02:00'),
    end:   DateTime.parse('2025-08-12T18:00:00+02:00'),
    title: 'Spin to park',
  ),

  // -------- Wed 2025-08-13 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-13T07:30:00+02:00'),
    end:   DateTime.parse('2025-08-13T08:45:00+02:00'),
    title: 'Intervals 4x5min',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-13T09:00:00+02:00'),
    end:   DateTime.parse('2025-08-13T12:00:00+02:00'),
    title: 'Deep work block',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-13T11:45:00+02:00'),
    end:   DateTime.parse('2025-08-13T12:15:00+02:00'),
    title: 'Call with landlord', // overlaps Work
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-13T13:00:00+02:00'),
    end:   DateTime.parse('2025-08-13T16:00:00+02:00'),
    title: 'Docs + refactor',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-13T18:15:00+02:00'),
    end:   DateTime.parse('2025-08-13T19:15:00+02:00'),
    title: 'Recovery spin',
  ),

  // -------- Thu 2025-08-14 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-14T06:00:00+02:00'),
    end:   DateTime.parse('2025-08-14T07:00:00+02:00'),
    title: 'Morning ride',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-14T09:00:00+02:00'),
    end:   DateTime.parse('2025-08-14T11:00:00+02:00'),
    title: 'Design review',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-14T11:15:00+02:00'),
    end:   DateTime.parse('2025-08-14T11:45:00+02:00'),
    title: 'Dentist',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-14T12:00:00+02:00'),
    end:   DateTime.parse('2025-08-14T15:00:00+02:00'),
    title: 'Implementation',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-14T17:00:00+02:00'),
    end:   DateTime.parse('2025-08-14T17:30:00+02:00'),
    title: 'Groceries pickup',
  ),

  // -------- Fri 2025-08-15 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-15T07:00:00+02:00'),
    end:   DateTime.parse('2025-08-15T08:30:00+02:00'),
    title: 'Tempo ride',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-15T09:00:00+02:00'),
    end:   DateTime.parse('2025-08-15T12:00:00+02:00'),
    title: 'Bug bash',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.work,
    start: DateTime.parse('2025-08-15T13:00:00+02:00'),
    end:   DateTime.parse('2025-08-15T16:30:00+02:00'),
    title: 'Release prep',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-15T20:00:00+02:00'),
    end:   DateTime.parse('2025-08-15T22:00:00+02:00'),
    title: 'Dinner with friends',
  ),

  // -------- Sat 2025-08-16 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-16T08:00:00+02:00'),
    end:   DateTime.parse('2025-08-16T11:45:00+02:00'),
    title: 'Long ride',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-16T12:00:00+02:00'),
    end:   DateTime.parse('2025-08-16T13:00:00+02:00'),
    title: 'Brunch',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-16T15:15:00+02:00'),
    end:   DateTime.parse('2025-08-16T16:00:00+02:00'),
    title: 'Errands',
  ),

  // -------- Sun 2025-08-17 --------
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.cycling,
    start: DateTime.parse('2025-08-17T09:30:00+02:00'),
    end:   DateTime.parse('2025-08-17T10:30:00+02:00'),
    title: 'Recovery spin',
  ),
  ScheduleInterval(
    userId: userId,
    type: ScheduleType.other,
    start: DateTime.parse('2025-08-17T12:00:00+02:00'),
    end:   DateTime.parse('2025-08-17T14:00:00+02:00'),
    title: 'Family time',
  ),
];
