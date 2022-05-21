import 'package:flutter/material.dart';

class MyDateTimePicker extends StatefulWidget {
  const MyDateTimePicker(
      {Key? key, this.restorationId, required this.setDateTime})
      : super(key: key);
  final Function setDateTime;
  final String? restorationId;

  @override
  State<MyDateTimePicker> createState() => _MyDateTimePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _MyDateTimePickerState extends State<MyDateTimePicker>
    with RestorationMixin {
  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2021),
          lastDate: DateTime(2023),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  Future<void> timePicker() async {
    final TimeOfDay? result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() {
        _selectedDate.value = DateTime(
          _selectedDate.value.year,
          _selectedDate.value.month,
          _selectedDate.value.day,
          result.hour,
          result.minute,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.hour}/${_selectedDate.value.minute}'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              _restorableDatePickerRouteFuture.present();
            },
            child: const Text('Open Date Picker'),
          ),
          OutlinedButton(
              onPressed: timePicker, child: const Text("Show Time Picker")),
          OutlinedButton(
              onPressed: () => widget.setDateTime(_selectedDate),
              child: const Text("submit"))
        ],
      ),
    );
  }
}
