import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_constants.dart';
import 'package:hackathon/view/scheduler/scheduler_controller.dart';
import 'package:kalender/kalender.dart';
import 'package:hackathon/model/schedule_interval.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:provider/provider.dart';

/// The SchedulerView is the main view for the scheduler.
/// It displays a calendar with events and allows the user to create, edit, and delete events.
/// It also displays a list of activities and allows the user to create, edit, and delete activities.
class SchedulerView extends StatefulWidget {
  const SchedulerView({super.key});

  @override
  State<SchedulerView> createState() => _SchedulerViewState();
}

class _SchedulerViewState extends State<SchedulerView> {
  final DefaultEventsController _events = DefaultEventsController();
  final CalendarController _calendar = CalendarController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _events.dispose();
    _calendar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SchedulerController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync data',
            onPressed: () async {
              // Initial load for current week.
              setState(() => _isLoading = true);
              final now = DateTime.now();
              final start = controller.startOfWeek(now);
              await _loadForRange(
                DateTimeRange(
                  start: start,
                  end: start.add(const Duration(days: 7)),
                ),
              );
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacings.m),
          child: Stack(
            children: [
              CalendarView(
                eventsController: _events,
                calendarController: _calendar,
                viewConfiguration:
                    MultiDayViewConfiguration.custom(numberOfDays: 3),
                header: CalendarHeader(
                  multiDayTileComponents:
                      TileComponents(tileBuilder: _eventTile),
                ),
                body: CalendarBody(
                  multiDayTileComponents:
                      TileComponents(tileBuilder: _eventTile),
                  snapping:
                      ValueNotifier(CalendarSnapping(snapIntervalMinutes: 15)),
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
                      final start = controller.snapTo15(dateTime);
                      final draft = CalendarEvent(
                        dateTimeRange: DateTimeRange(
                            start: start,
                            end: start.add(const Duration(hours: 1))),
                        data: null,
                      );
                      _events.addEvent(draft);
                      final saved =
                          await _openCreateDialog(draft.dateTimeRange);
                      if (saved == null) {
                        _events.removeEvent(draft);
                      } else {
                        _events.updateEvent(
                          event: draft,
                          updatedEvent: draft.copyWith(
                            dateTimeRange: DateTimeRange(
                                start: saved.start, end: saved.end),
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
                      final saved =
                          await _openCreateDialog(event.dateTimeRange);
                      if (saved == null) {
                        _events.removeEvent(event);
                      } else {
                        _events.updateEvent(
                          event: event,
                          updatedEvent: event.copyWith(
                            data: saved,
                            dateTimeRange: DateTimeRange(
                                start: saved.start, end: saved.end),
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
                        await _openEditDialog(data);
                      }
                    }();
                  },
                  // Drag/resize → persist; rollback on failure.
                  onEventChanged: (previous, updated) {
                    () async {
                      final s = previous.data is ScheduleInterval
                          ? previous.data as ScheduleInterval
                          : null;
                      if (s == null) return;
                      // Block updates for unsynced events (no ID yet)
                      if (s.id == null || s.id!.isEmpty) {
                        _showError(
                            'Event is syncing. Please try again shortly.');
                        _events.updateEvent(
                            event: updated, updatedEvent: previous);
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
                        await Provider.of<SchedulerController>(context,
                                listen: false)
                            .updateInterval(updatedInterval);
                        _events.updateEvent(
                          event: updated,
                          updatedEvent: updated.copyWith(data: updatedInterval),
                        );
                      } catch (e) {
                        _showError('Failed to update interval: $e');
                        _events.updateEvent(
                            event: updated,
                            updatedEvent: previous); // rollback visuals
                      }
                    }();
                  },
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventTile(CalendarEvent event, DateTimeRange tileRange) {
    final controller = Provider.of<SchedulerController>(context);
    final s =
        event.data is ScheduleInterval ? event.data as ScheduleInterval : null;
    final a =
        event.data is CyclingActivity ? event.data as CyclingActivity : null;
    final bg = a != null
        ? controller.bgFor(ScheduleType.cycling)
        : controller.bgFor(s?.type);
    final title = a != null
        ? 'Cycling'
        : (s?.title?.trim().isNotEmpty ?? false)
            ? s!.title!.trim()
            : (s != null ? scheduleTypeToString(s.type) : 'New interval');

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacings.s, vertical: Spacings.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: controller.fgFor(bg, context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _loadForRange(DateTimeRange range) async {
    setState(() => _isLoading = true);
    try {
      final events =
          await Provider.of<SchedulerController>(context, listen: false)
              .buildEventsForRange(range);
      _events.clearEvents();
      _events.addEvents(events);
    } catch (e) {
      _showError('Failed to load: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _openEditDialog(ScheduleInterval original) async {
    final saved = await _openEditOrCreateDialog(original, isCreate: false);
    if (saved != null) {
      // Refresh visible range so changes propagate reliably on web
      final range = _calendar.visibleDateTimeRange.value;
      _loadForRange(range);
    }
  }

  Future<ScheduleInterval?> _openEditOrCreateDialog(
    ScheduleInterval base, {
    required bool isCreate,
  }) async {
    final titleCtrl = TextEditingController(text: base.title ?? '');
    final descCtrl = TextEditingController(text: base.description ?? '');
    ScheduleType selectedType = base.type;
    DateTime startAt = base.start;
    DateTime endAt = base.end;
    final controller = Provider.of<SchedulerController>(context);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInner) {
            Future<void> pickStart() async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: startAt,
              );
              if (d == null) return;
              final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(startAt));
              if (t == null) return;
              setInner(() {
                startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                if (!startAt.isBefore(endAt)) {
                  endAt = startAt.add(const Duration(minutes: 30));
                }
              });
            }

            Future<void> pickEnd() async {
              final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: endAt);
              if (d == null) return;
              final t = await showTimePicker(
                  context: context, initialTime: TimeOfDay.fromDateTime(endAt));
              if (t == null) return;
              setInner(() {
                endAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                if (!startAt.isBefore(endAt)) {
                  startAt = endAt.subtract(const Duration(minutes: 30));
                }
              });
            }

            return AlertDialog(
              title: Text(isCreate ? 'Create interval' : 'Edit interval'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: Spacings.m),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Description', alignLabelWithHint: true),
                      maxLines: 3,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: Spacings.m),
                    DropdownButtonFormField<ScheduleType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ScheduleType.values
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(scheduleTypeToString(s))))
                          .toList(),
                      onChanged: (v) => setInner(() {
                        if (v != null) selectedType = v;
                      }),
                    ),
                    const SizedBox(height: Spacings.m),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start'),
                      subtitle: Text(controller.formatDT(context, startAt)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: pickStart,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End'),
                      subtitle: Text(controller.formatDT(context, endAt)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: pickEnd,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (!startAt.isBefore(endAt)) return;
                    try {
                      // Persist in UTC to avoid cross-timezone skew
                      final updated = ScheduleInterval(
                        id: base.id,
                        userId: base.userId,
                        type: selectedType,
                        start: startAt.toUtc(),
                        end: endAt.toUtc(),
                        title: titleCtrl.text.trim().isEmpty
                            ? null
                            : titleCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                      );
                      if (isCreate) {
                        await Provider.of<SchedulerController>(context,
                                listen: false)
                            .insertInterval(updated);
                        base =
                            updated; // server will assign ID; caller will trigger reload
                      } else {
                        await Provider.of<SchedulerController>(context,
                                listen: false)
                            .updateInterval(updated);
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
