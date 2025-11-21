import 'package:flutter/material.dart';
import 'inputs/modern_date_picker.dart';

/// Reusable time range picker widget for selecting start and end times
/// 
/// Displays two time pickers side by side with a visual separator,
/// allowing users to select a time range (start to end).
/// 
/// Example:
/// ```dart
/// TimeRangePicker(
///   startTime: _startTime,
///   endTime: _endTime,
///   onStartTimeChanged: (time) => setState(() => _startTime = time),
///   onEndTimeChanged: (time) => setState(() => _endTime = time),
///   errorText: _timeError,
/// )
/// ```
class TimeRangePicker extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final ValueChanged<DateTime> onStartTimeChanged;
  final ValueChanged<DateTime> onEndTimeChanged;
  final String? errorText;
  final String startLabel;
  final String endLabel;
  final IconData startIcon;
  final IconData endIcon;
  final IconData separatorIcon;

  const TimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    this.errorText,
    this.startLabel = 'Inicio',
    this.endLabel = 'Fin',
    this.startIcon = Icons.schedule,
    this.endIcon = Icons.timer_off_outlined,
    this.separatorIcon = Icons.arrow_forward,
  });

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initial = isStart ? startTime : endTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    
    if (time != null) {
      final newDateTime = DateTime(
        initial.year,
        initial.month,
        initial.day,
        time.hour,
        time.minute,
      );
      
      if (isStart) {
        onStartTimeChanged(newDateTime);
      } else {
        onEndTimeChanged(newDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ModernDatePicker(
            label: startLabel,
            value: startTime,
            isTime: true,
            icon: startIcon,
            errorText: errorText,
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          separatorIcon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ModernDatePicker(
            label: endLabel,
            value: endTime,
            isTime: true,
            icon: endIcon,
            onTap: () => _selectTime(context, false),
          ),
        ),
      ],
    );
  }
}
