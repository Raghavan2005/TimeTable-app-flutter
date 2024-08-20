import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable CSE F',
      debugShowCheckedModeBanner: false,
      home: TimetableScreen(),
    );
  }
}

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String selectedDay = DateFormat('EEEE').format(DateTime.now());

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  final List<Lecture> timetable = [
    // Tuesday
    Lecture(
        'CS23332',
        'Database Management Systems (DBMS)',
        'A308',
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 9, minute: 0),
        'Tuesday'),
  ];
  @override
  Widget build(BuildContext context) {
    List<Lecture> dayLectures = getLecturesForDay(selectedDay);

    Lecture? currentClass;
    Lecture? nextClass;

    for (int i = 0; i < dayLectures.length; i++) {
      if (isCurrentClass(dayLectures[i])) {
        currentClass = dayLectures[i];
      } else if (isUpcomingClass(dayLectures[i])) {
        nextClass = dayLectures[i];
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: selectedDay,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.blue,
          style: TextStyle(color: Colors.white),
          underline: Container(),
          onChanged: (String? newValue) {
            setState(() {
              selectedDay = newValue!;
            });
          },
          items: days.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            );
          }).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Class:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (currentClass != null) ...[
              GestureDetector(
                onTap: () {
                  showClassDetails(context, currentClass!);
                },
                child: Text(
                  '${currentClass!.name} (${currentClass!.room})',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Text(
                  'Time: ${currentClass!.start.format(context)} - ${currentClass!.end.format(context)}'),
            ] else ...[
              Text('No class currently'),
            ],
            SizedBox(height: 20),
            const Text('Upcoming Class:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (nextClass != null) ...[
              GestureDetector(
                onTap: () {
                  showClassDetails(context, nextClass!);
                },
                child: Text('${nextClass!.name} (${nextClass!.room})'),
              ),
              Text(
                  'Time: ${nextClass!.start.format(context)} - ${nextClass!.end.format(context)}'),
            ] else ...[
              Text('No upcoming class today'),
            ],
          ],
        ),
      ),
    );
  }

  List<Lecture> getLecturesForDay(String day) {
    return timetable.where((lecture) => lecture.day == day).toList();
  }

  bool isCurrentClass(Lecture lecture) {
    TimeOfDay now = TimeOfDay.now();
    return (now.hour == lecture.start.hour &&
            now.minute >= lecture.start.minute) ||
        (now.hour == lecture.end.hour && now.minute <= lecture.end.minute) ||
        (now.hour > lecture.start.hour && now.hour < lecture.end.hour);
  }

  bool isUpcomingClass(Lecture lecture) {
    TimeOfDay now = TimeOfDay.now();
    return now.hour < lecture.start.hour ||
        (now.hour == lecture.start.hour && now.minute < lecture.start.minute);
  }

  void showClassDetails(BuildContext context, Lecture lecture) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lecture.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Course Code: ${lecture.code}'),
              Text('Room: ${lecture.room}'),
              Text(
                  'Time: ${lecture.start.format(context)} - ${lecture.end.format(context)}'),
              Text('Day: ${lecture.day}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Lecture {
  final String code;
  final String name;
  final String room;
  final TimeOfDay start;
  final TimeOfDay end;
  final String day;

  Lecture(this.code, this.name, this.room, this.start, this.end, this.day);
}
