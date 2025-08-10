import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/model/schedule_interval.dart';
import 'package:hackathon/dto/schedule_interval_dto.dart';
import 'package:hackathon/dto/cycling_activity_dto.dart';

/// The SchedulerController is the controller for the scheduler.
///
/// It handles the data loading and mapping for the scheduler, the calendar assembly
/// and the event tile builder.
/// It also handles the persistence of the schedule intervals and cycling activities.
class SchedulerController extends ChangeNotifier {
  final List<CyclingActivity> activities = [];

  /// Returns the start of the week for a given date.
  ///
  /// The week starts on Monday.
  DateTime startOfWeek(DateTime d) {
    final int weekday = d.weekday; // 1 = Monday
    return DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: weekday - 1));
  }

  /// Rounds a given date to the nearest 15 minutes.
  ///
  /// This is used to snap the calendar to 15-minute intervals.
  DateTime snapTo15(DateTime dt) {
    final int minutes = (dt.minute ~/ 15) * 15;
    return DateTime(dt.year, dt.month, dt.day, dt.hour, minutes);
  }

  /// Reads the schedule intervals for a given date range.
  ///
  /// The intervals are returned as a list of [ScheduleInterval] objects.
  Future<List<ScheduleInterval>> readIntervals({
    required DateTime start,
    required DateTime end,
  }) async {
    return ScheduleIntervalDto.readIntervals(start: start, end: end);
  }

  /// Reads the cycling activities for a given date range.
  ///
  /// The activities are returned as a list of [CyclingActivity] objects.
  Future<List<CyclingActivity>> readCyclingActivities({
    required DateTime start,
    required DateTime end,
  }) async {
    return CyclingActivityDto.loadActivities(start: start, end: end);
  }

  /// Builds the calendar events for a given date range.
  ///
  /// The events are returned as a list of [CalendarEvent] objects.
  Future<List<CalendarEvent>> buildEventsForRange(DateTimeRange range) async {
    final List<ScheduleInterval> intervals = await readIntervals(
      start: range.start.toUtc(),
      end: range.end.toUtc(),
    );
    final List<CyclingActivity> acts = await readCyclingActivities(
      start: range.start.toUtc(),
      end: range.end.toUtc(),
    );
    final List<CalendarEvent> events = <CalendarEvent>[
      ...intervals.map(toEvent),
      ...acts.map(activityToEvent),
    ];
    return events;
  }

  /// Converts a [ScheduleInterval] to a [CalendarEvent].
  ///
  /// The event is returned as a [CalendarEvent] object.
  CalendarEvent toEvent(ScheduleInterval s) {
    final DateTime startUtc = s.start.isUtc ? s.start : s.start.toUtc();
    final DateTime endUtc = s.end.isUtc ? s.end : s.end.toUtc();
    return CalendarEvent(
      dateTimeRange: DateTimeRange(start: startUtc, end: endUtc),
      data: s,
    );
  }

  /// Converts a [CyclingActivity] to a [CalendarEvent].
  ///
  /// The event is returned as a [CalendarEvent] object.
  CalendarEvent activityToEvent(CyclingActivity a) {
    final DateTime startUtc =
        a.startTime.isUtc ? a.startTime : a.startTime.toUtc();
    final DateTime endUtc = a.endTime.isUtc ? a.endTime : a.endTime.toUtc();
    return CalendarEvent(
      dateTimeRange: DateTimeRange(start: startUtc, end: endUtc),
      data: a,
    );
  }

  /// Returns the background color for a given schedule type.
  ///
  /// The color is returned as a [Color] object.
  Color bgFor(ScheduleType? t) {
    switch (t) {
      case ScheduleType.cycling:
        return Colors.green.shade600;
      case ScheduleType.work:
        return Colors.blue.shade600;
      case ScheduleType.other:
        return Colors.orange.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  /// Returns the foreground color for a given background color.
  ///
  /// The color is returned as a [Color] object.
  Color fgFor(Color bg, BuildContext context) => bg.computeLuminance() > 0.5
      ? Theme.of(context).colorScheme.onSurface
      : Theme.of(context).colorScheme.surface;

  /// Updates a [ScheduleInterval] in the database.
  ///
  /// The interval is updated in the database.
  Future<void> updateInterval(ScheduleInterval interval) async {
    await ScheduleIntervalDto.updateInterval(interval);
  }

  /// Inserts a [ScheduleInterval] into the database.
  ///
  /// The interval is inserted into the database.
  Future<void> insertInterval(ScheduleInterval interval) async {
    await ScheduleIntervalDto.insertInterval(interval);
  }

  /// Formats a [DateTime] object as a string.
  ///
  /// The string is returned as a [String] object.
  String formatDT(BuildContext context, DateTime dt, {bool use24h = true}) {
    final l = MaterialLocalizations.of(context);
    final date = l.formatFullDate(dt.toLocal()); // display local
    final time = l.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt.toLocal()),
      alwaysUse24HourFormat: use24h,
    ); // e.g., 14:30
    return '$date, $time';
  }
}
