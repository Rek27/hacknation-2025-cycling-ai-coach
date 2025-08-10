import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/themes/app_constants.dart';
import 'package:intl/intl.dart';

class AddActivityDialog extends StatefulWidget {
  const AddActivityDialog({super.key});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _distanceCtrl = TextEditingController();
  final TextEditingController _durationMinCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _avgHrCtrl = TextEditingController();
  final TextEditingController _maxHrCtrl = TextEditingController();

  DateTime _start = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _end = DateTime.now();

  Future<void> _pickStart() async {
    final DateTime? d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _start,
    );
    if (d == null) return;
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (t == null) return;
    setState(() {
      _start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      if (!_start.isBefore(_end)) {
        _end = _start.add(const Duration(minutes: 30));
      }
    });
  }

  Future<void> _pickEnd() async {
    final DateTime? d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _end,
    );
    if (d == null) return;
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (t == null) return;
    setState(() {
      _end = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      if (!_start.isBefore(_end)) {
        _start = _end.subtract(const Duration(minutes: 30));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double dialogWidth =
        (MediaQuery.of(context).size.width * 0.9).clamp(360.0, 520.0);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      title: const Text('Add cycling activity'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Title (optional)'),
              ),
              const SizedBox(height: Spacings.m),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _distanceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Distance (km)'),
                    ),
                  ),
                  const SizedBox(width: Spacings.m),
                  Expanded(
                    child: TextField(
                      controller: _durationMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Duration (min)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacings.m),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _kcalCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Energy (kcal)'),
                    ),
                  ),
                  const SizedBox(width: Spacings.m),
                  Expanded(
                    child: TextField(
                      controller: _avgHrCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Avg HR (bpm)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacings.m),
              TextField(
                controller: _maxHrCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max HR (bpm)'),
              ),
              const SizedBox(height: Spacings.m),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start'),
                subtitle: Text(_formatFriendly(_start)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickStart,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End'),
                subtitle: Text(_formatFriendly(_end)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickEnd,
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: Spacings.m),
        ElevatedButton(
          onPressed: () {
            if (!_start.isBefore(_end)) return;
            final double distanceKm =
                double.tryParse(_distanceCtrl.text.trim()) ?? 0;
            final int durationMin =
                int.tryParse(_durationMinCtrl.text.trim()) ?? 0;
            final double kcal = double.tryParse(_kcalCtrl.text.trim()) ?? 0;
            final double? avgHr = double.tryParse(_avgHrCtrl.text.trim());
            final double? maxHr = double.tryParse(_maxHrCtrl.text.trim());

            final activity = CyclingActivity(
              startTime: _start,
              endTime: _end,
              duration: Duration(minutes: durationMin),
              distanceKm: distanceKm,
              averageSpeedKmh:
                  durationMin > 0 ? distanceKm / (durationMin / 60.0) : 0,
              activeEnergyKcal: kcal,
              elevationGainMeters: null,
              averageHeartRateBpm: avgHr,
              maxHeartRateBpm: maxHr,
              vo2Max: null,
            );
            Navigator.pop(context, activity);
          },
          child: const Text('Add activity'),
        ),
      ],
    );
  }
}

String _formatFriendly(DateTime dt) {
  final DateTime local = dt.toLocal();
  final String monthDay = DateFormat('MMM d').format(local); // e.g. Sep 23
  final String suffix = _daySuffix(local.day);
  final String hm = DateFormat('HH:mm').format(local);
  return '$monthDay$suffix, $hm';
}

String _daySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}
