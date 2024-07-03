import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sample events data
  final Map<DateTime, List<String>> _events = {
    // DateTime.now().add(Duration(days: 1)): ['Event 1', 'Event 2'],
    // DateTime.now().add(Duration(days: 3)): ['Event 3'],
    // DateTime.now().add(Duration(days: 5)): ['Event 4', 'Event 5'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar with Events'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: UpcomingEventsList(events: _events),
          ),
        ],
      ),
    );
  }
}

class UpcomingEventsList extends StatelessWidget {
  final Map<DateTime, List<String>> events;

  const UpcomingEventsList({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEvents = events.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final date = sortedEvents[index].key;
        final eventList = sortedEvents[index].value;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: eventList
                .map((event) => ListTile(
                      title: Text(event),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
