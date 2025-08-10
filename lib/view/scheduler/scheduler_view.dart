import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:hackathon/dto/schedule_interval_dto.dart';
import 'package:hackathon/model/schedule_interval.dart';
import 'package:hackathon/dto/cycling_activity_dto.dart';
import 'package:hackathon/model/cycling_activity.dart' as activity_model;

class SchedulerView extends StatefulWidget {
  const SchedulerView({super.key});

  @override
  State<SchedulerView> createState() => _SchedulerViewState();
}

class _SchedulerViewState extends State<SchedulerView> {
  final DefaultEventsController _events = DefaultEventsController();
  final CalendarController _calendar = CalendarController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initial load for current week.
    final now = DateTime.now();
    final start = _startOfWeek(now);
    _loadForRange(DateTimeRange(start: start, end: start.add(const Duration(days: 7))));
  }

  @override
  void dispose() {
    _events.dispose();
    _calendar.dispose();
    super.dispose();
  }

  // --- Colors per category ---
  Color _bgFor(ScheduleType? t) {
    switch (t) {
      case ScheduleType.cycling: return Colors.green.shade600;
      case ScheduleType.work:    return Colors.blue.shade600;
      case ScheduleType.other:   return Colors.orange.shade600;
      default: return Theme.of(context).colorScheme.secondaryContainer;
    }
  }

  Color _fgFor(Color bg) => bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  // --- Unified tile builder for header/body (fixes "Tile" text) ---
  Widget _eventTile(CalendarEvent event, DateTimeRange tileRange) {
    final s = event.data is ScheduleInterval ? event.data as ScheduleInterval : null;
    final a = event.data is activity_model.CyclingActivity ? event.data as activity_model.CyclingActivity : null;

    if (s != null) {
      final bg = _bgFor(s.type);
      final title = (s.title?.trim().isNotEmpty ?? false)
          ? s.title!.trim()
          : scheduleTypeToString(s.type);
      final desc = s.description;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _fgFor(bg), fontWeight: FontWeight.w600)),
            if (desc != null && desc.isNotEmpty)
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _fgFor(bg)),
              ),
          ],
        ),
      );
    }

    if (a != null) {
      final bg = Colors.purple.shade600;
      final fg = _fgFor(bg);
      final distance = '${a.distanceKm.toStringAsFixed(1)} km';
      final speed = '${a.averageSpeedKmh.toStringAsFixed(1)} km/h';
      final title = 'Ride $distance @ $speed';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: fg.withOpacity(0.6), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.directions_bike, size: 14, color: fg),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // Fallback
    final bg = Theme.of(context).colorScheme.secondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text('Event', style: TextStyle(color: _fgFor(bg))),
    );
  }


  String _formatDT(BuildContext context, DateTime dt, {bool use24h = true}) {
    final l = MaterialLocalizations.of(context);
    final date = l.formatFullDate(dt); // e.g., Monday, August 11, 2025
    final time = l.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: use24h,
    ); // e.g., 14:30
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(/* ... */),
      body: Stack(
        children: [
          CalendarView(
            eventsController: _events,
            calendarController: _calendar,
            viewConfiguration: MultiDayViewConfiguration.custom(numberOfDays: 3),
            // Use the same custom tiles in both header & body:
            header: CalendarHeader(
              multiDayTileComponents: TileComponents(tileBuilder: _eventTile),
            ), // header supports multiDayTileComponents. :contentReference[oaicite:1]{index=1}
            body: CalendarBody(
              multiDayTileComponents: TileComponents(tileBuilder: _eventTile),
              // CalendarBody exposes multiDayTileComponents. :contentReference[oaicite:2]{index=2}
              snapping: ValueNotifier(CalendarSnapping(snapIntervalMinutes: 15)),
              interaction: ValueNotifier(CalendarInteraction(
                allowEventCreation: true,
                allowRescheduling: true,
                allowResizing: true,
              )),
            ),
            // Calendar behavior hooks (paging, taps, create, drag/resize).
            callbacks: CalendarCallbacks(
          // When the visible page (week) changes, reload from DB.
          onPageChanged: (visible) => _loadForRange(visible),
          // Tap on empty space → create 60-min draft and open form.
          onTapped: (dateTime) {
            () async {
              final start = _snapTo15(dateTime);
              final draft = CalendarEvent(
                dateTimeRange: DateTimeRange(start: start, end: start.add(const Duration(hours: 1))),
                data: null,
              );
              _events.addEvent(draft);
              final saved = await _openCreateDialog(draft.dateTimeRange);
              if (saved == null) {
                _events.removeEvent(draft);
              } else {
                _events.updateEvent(
                  event: draft,
                  updatedEvent: draft.copyWith(
                    dateTimeRange: DateTimeRange(start: saved.start, end: saved.end),
                  ),
                );
                // Ensure server-generated IDs are reflected
                final range = _calendar.visibleDateTimeRange.value;
                _loadForRange(range);
              }
            }();
          },
          // After a new event is created via drag long-press gesture, open form.
          onEventCreated: (event) {
            () async {
              // If user drags to create; attach details via dialog.
              final saved = await _openCreateDialog(event.dateTimeRange);
              if (saved == null) {
                _events.removeEvent(event);
              } else {
                _events.updateEvent(
                  event: event,
                  updatedEvent: event.copyWith(
                    data: saved,
                    dateTimeRange: DateTimeRange(start: saved.start, end: saved.end),
                  ),
                );
                // Ensure server-generated IDs are reflected
                final range = _calendar.visibleDateTimeRange.value;
                _loadForRange(range);
              }
            }();
          },
          // Tap event → open edit.
          onEventTapped: (event, renderBox) {
            () async {
              final data = event.data;
              if (data is ScheduleInterval) {
                await _openEditDialog(data, eventRef: event); // pass event reference
              } else if (data is activity_model.CyclingActivity) {
                final a = data;
                if (!mounted) return;
                showDialog<void>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Ride details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start: ${_formatDT(ctx, a.startTime)}'),
                          Text('End:   ${_formatDT(ctx, a.endTime)}'),
                          const SizedBox(height: 8),
                          Text('Distance: ${a.distanceKm.toStringAsFixed(1)} km'),
                          Text('Speed:    ${a.averageSpeedKmh.toStringAsFixed(1)} km/h'),
                          if (a.elevationGainMeters != null)
                            Text('Elevation: ${a.elevationGainMeters!.toStringAsFixed(0)} m'),
                          if (a.averageHeartRateBpm != null)
                            Text('Avg HR: ${a.averageHeartRateBpm!.toStringAsFixed(0)} bpm'),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                      ],
                    );
                  },
                );
              }
            }();
          },
          // Drag/resize → persist; rollback on failure.
          onEventChanged: (previous, updated) {
            () async {
              final isActivity = previous.data is activity_model.CyclingActivity;
              if (isActivity) {
                _showError('Rides are read-only.');
                _events.updateEvent(event: updated, updatedEvent: previous);
                return;
              }

              final s = previous.data is ScheduleInterval ? previous.data as ScheduleInterval : null;
              if (s == null) {
                _events.updateEvent(event: updated, updatedEvent: previous);
                return;
              }
              // Block updates for unsynced events (no ID yet)
              if (s.id == null || s.id!.isEmpty) {
                _showError('Event is syncing. Please try again shortly.');
                _events.updateEvent(event: updated, updatedEvent: previous);
                return;
              }

              final updatedInterval = ScheduleInterval(
                id: s.id,
                userId: s.userId,
                type: s.type,
                start: updated.dateTimeRange.start,
                end: updated.dateTimeRange.end,
                title: s.title,
                description: s.description,
              );

              try {
                await ScheduleIntervalDto.updateInterval(updatedInterval);
                _events.updateEvent(
                  event: updated,
                  updatedEvent: updated.copyWith(data: updatedInterval),
                );
              } catch (e) {
                _showError('Failed to update interval: $e');
                _events.updateEvent(event: updated, updatedEvent: previous); // rollback visuals
              }
            }();
          },
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== Data load & mapping =================================================

  Future<void> _loadForRange(DateTimeRange range) async {
    setState(() => _isLoading = true);
    try {
      final items = await ScheduleIntervalDto.readIntervals(start: range.start, end: range.end);
      final rides = await CyclingActivityDto.loadActivities(
        start: range.start,
        end: range.end,
        userId: '00000000-0000-0000-0000-000000000000',
      );
      _events.clearEvents();
      _events.addEvents([
        ...items.map(_toEvent),
        ...rides.map(_toActivityEvent),
      ]);
    } catch (e) {
      _showError('Failed to load: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  CalendarEvent _toEvent(ScheduleInterval s) {
    return CalendarEvent(
      dateTimeRange: DateTimeRange(start: s.start, end: s.end),
      data: s, // attach your model for easy retrieval
    );
  }

  CalendarEvent _toActivityEvent(activity_model.CyclingActivity a) {
    return CalendarEvent(
      dateTimeRange: DateTimeRange(start: a.startTime, end: a.endTime),
      data: a,
    );
  }

  // ===== Dialogs =============================================================

  Future<void> _confirmDelete(CalendarEvent event) async {
    final s = event.data is ScheduleInterval ? event.data as ScheduleInterval : null;
    if (s == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete interval?'),
        content: Text(
          (s.title?.isNotEmpty ?? false) ? '“${s.title}”' : scheduleTypeToString(s.type),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      // Backend delete if we have a server ID.
      if (s.id != null && s.id!.isNotEmpty) {
        await ScheduleIntervalDto.deleteIntervalById(s.id!);
      }
      // Remove from the controller immediately for snappy UX.
      _events.removeEvent(event);

      // Reload visible range to stay canonical (esp. web).
      final range = _calendar.visibleDateTimeRange.value;
      _loadForRange(range);
    } catch (e) {
      _showError('Failed to delete: $e');
    }
  }

  Future<ScheduleInterval?> _openCreateDialog(DateTimeRange slot) async {
    final ScheduleInterval draft = ScheduleInterval(
      userId: '00000000-0000-0000-0000-000000000000',
      type: ScheduleType.cycling,
      start: slot.start,
      end: slot.end,
      title: 'New interval',
      description: null,
    );
    return _openEditOrCreateDialog(draft, isCreate: true);
  }

  Future<void> _openEditDialog(ScheduleInterval original, {CalendarEvent? eventRef}) async {
    final saved = await _openEditOrCreateDialog(original, isCreate: false, eventRef: eventRef);
    if (saved != null) {
      final range = _calendar.visibleDateTimeRange.value;
      _loadForRange(range);
    }
  }

  Future<ScheduleInterval?> _openEditOrCreateDialog(
      ScheduleInterval base, {
        required bool isCreate,
        CalendarEvent? eventRef,
      }) async {
    final titleCtrl = TextEditingController(text: base.title ?? '');
    final descCtrl = TextEditingController(text: base.description ?? '');
    ScheduleType selectedType = base.type;
    DateTime startAt = base.start;
    DateTime endAt = base.end;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInner) {
            Future<void> pickStart() async {
              final d = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: startAt);
              if (d == null) return;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startAt));
              if (t == null) return;
              setInner(() {
                startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                if (!startAt.isBefore(endAt)) endAt = startAt.add(const Duration(minutes: 30));
              });
            }

            Future<void> pickEnd() async {
              final d = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: endAt);
              if (d == null) return;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endAt));
              if (t == null) return;
              setInner(() {
                endAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                if (!startAt.isBefore(endAt)) startAt = endAt.subtract(const Duration(minutes: 30));
              });
            }

            return AlertDialog(
              title: Text(isCreate ? 'Create interval' : 'Edit interval'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 8),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ScheduleType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ScheduleType.values.map((s) => DropdownMenuItem(value: s, child: Text(scheduleTypeToString(s)))).toList(),
                      onChanged: (v) => setInner(() {
                        if (v != null) selectedType = v;
                      }),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start'),
                      subtitle: Text(_formatDT(context, startAt)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: pickStart,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End'),
                      subtitle: Text(_formatDT(context, endAt)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: pickEnd,
                    ),
                  ],
                ),
              ),
              actions: [
                if (!isCreate)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      // Prefer using the tapped event ref if available (removes exact instance).
                      if (eventRef != null) {
                        await _confirmDelete(eventRef);
                      } else {
                        // Fallback: delete by id and remove by predicate.
                        if (base.id != null && base.id!.isNotEmpty) {
                          await ScheduleIntervalDto.deleteIntervalById(base.id!);
                        }
                        _events.removeWhere((e) {
                          final d = e.data;
                          return d is ScheduleInterval && d.id == base.id;
                        } as bool Function(int key, CalendarEvent<Object?> element));
                        final range = _calendar.visibleDateTimeRange.value;
                        _loadForRange(range);
                      }
                      if (context.mounted) Navigator.pop(context, false);
                    },
                    label: const Text('Delete'),
                  ),
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (!startAt.isBefore(endAt)) return;
                    try {
                      final updated = ScheduleInterval(
                        id: base.id,
                        userId: base.userId,
                        type: selectedType,
                        start: startAt,
                        end: endAt,
                        title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      );
                      if (isCreate) {
                        await ScheduleIntervalDto.insertInterval(updated);
                        base = updated; // server will assign ID; caller will trigger reload
                      } else {
                        await ScheduleIntervalDto.updateInterval(updated);
                        base = updated;
                      }
                      if (context.mounted) Navigator.pop(context, true);
                    } catch (e) {
                      _showError('Failed to save: $e');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return saved == true ? base : null;
  }

  // ===== Helpers =============================================================

  DateTime _startOfWeek(DateTime d) {
    final weekday = d.weekday; // 1=Mon
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }

  DateTime _snapTo15(DateTime dt) {
    final minutes = (dt.minute ~/ 15) * 15;
    return DateTime(dt.year, dt.month, dt.day, dt.hour, minutes);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
