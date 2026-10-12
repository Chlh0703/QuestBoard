import 'package:flutter/material.dart';

import '../services/datetime_service.dart';

Future<DateTime?> selectDueDate(
    BuildContext context,
    DateTime? currentDueDate, {
      DateTime? maximumDueDate,
    }) async {
  final now = DateTime.now();

  final option = await showDialog<String>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Due Date'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, 'today');
            },
            child: const Text('Today'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, 'tomorrow');
            },
            child: const Text('Tomorrow'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, 'nextWeek');
            },
            child: const Text('Next week'),
          ),
          if (maximumDueDate != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'maxLength');
              },
              child: const Text('Max Length'),
            ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, 'custom');
            },
            child: const Text('Custom...'),
          ),
          if (currentDueDate != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'remove');
              },
              child: const Text('Remove deadline'),
            ),
        ],
      );
    },
  );

  if (option == null) {
    return currentDueDate;
  }

  if (option == 'remove') {
    return null;
  }

  DateTime? selectedDate;

  if (option == 'today') {
    selectedDate = DateTimeService.endOfDay(now);
  } else if (option == 'tomorrow') {
    selectedDate = DateTimeService.endOfDay(
      now.add(const Duration(days: 1)),
    );
  } else if (option == 'nextWeek') {
    selectedDate = DateTimeService.endOfDay(
      now.add(const Duration(days: 7)),
    );
  } else if (option == 'maxLength') {
    selectedDate = maximumDueDate;
  } else {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: maximumDueDate ?? DateTime(now.year + 10),
    );

    if (date == null) {
      return currentDueDate;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: currentDueDate != null
          ? TimeOfDay.fromDateTime(currentDueDate)
          : TimeOfDay.now(),
    );

    if (time == null) {
      return currentDueDate;
    }

    selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  if (maximumDueDate != null &&
      selectedDate != null &&
      selectedDate.isAfter(maximumDueDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'The deadline cannot be later than the quest deadline.',
        ),
      ),
    );

    return currentDueDate;
  }

  return selectedDate;
}