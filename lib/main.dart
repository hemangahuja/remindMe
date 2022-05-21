import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:testing_windows/date.dart';
import 'package:testing_windows/input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testing_windows/notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MyNotification.configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late RestorableDateTime dt;
  late String reminderText;
  late SharedPreferences prefs;
  bool isReminderSet = false;
  List<String> reminders = [];
  @override
  void initState() {
    super.initState();
    reminderText = '';
    asyncInitState();
  }

  Future<void> asyncInitState() async {
    prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    final reminders = (prefs.getStringList('reminders') ?? [])
        .where((reminder) => DateTime.fromMillisecondsSinceEpoch(
                int.parse(reminder.split(" ")[0]))
            .isAfter(now))
        .toList();
    prefs.setStringList("reminders", reminders);
    this.reminders = reminders;
    setState(() {});
  }

  bool checkIfReminderIsForThePast(BuildContext context,
      {RestorableDateTime? time}) {
    RestorableDateTime dt = time ?? this.dt;
    if (dt.value.isBefore(DateTime.now())) {
      debugPrint("DateTime is before now");
      snackBarMessage("Reminder Time is in the past!", context);
      return false;
    }
    return true;
  }

  void setDateTime(RestorableDateTime dt, BuildContext context) {
    if (!checkIfReminderIsForThePast(context, time: dt)) {
      return;
    }

    setState(() {
      this.dt = dt;
    });
    snackBarMessage(
        "Reminder time set to ${dt.value.toIso8601String()}", context);
    isReminderSet = true;
  }

  void setReminderText(String text) {
    setState(() {
      reminderText = text;
    });
  }

  void snackBarMessage(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  void addReminder(BuildContext context) async {
    if (reminderText.isEmpty ||
        !isReminderSet ||
        !checkIfReminderIsForThePast(context)) {
      snackBarMessage('Please enter a reminder', context);
      return;
    }

    final reminderAsString = "${dt.value.millisecondsSinceEpoch} $reminderText";
    setState(() {
      reminders.add(reminderAsString);
    });
    await prefs.setStringList('reminders', reminders);
    await MyNotification.scheduleNotification(
      flutterLocalNotificationsPlugin,
      dt,
      reminderText,
    );
    snackBarMessage('Reminder added', context);
  }

  String formatReminder(String reminder) {
    final reminderAsString = reminder.split(" ");
    final date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(reminderAsString[0]));
    final time = TimeOfDay.fromDateTime(date);
    final formattedReminder = "${time.format(context)} ${reminderAsString[1]}";
    return formattedReminder;
  }

  void refresh() async {
    await asyncInitState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Set Reminders'),
          ),
          body: Builder(builder: (BuildContext context) {
            return Center(
                child: Column(
              children: [
                const Text("Reminders So Far"),
                for (String reminder in reminders)
                  Text(formatReminder(reminder)),
                TextButton(onPressed: refresh, child: const Text("Refresh")),
                MyInput(onSubmitted: setReminderText),
                MyDateTimePicker(
                    setDateTime: (value) => setDateTime(value, context)),
                TextButton(
                    onPressed: () => addReminder(context),
                    child: const Text("Add Reminder")),
              ],
            ));
          })));
}
