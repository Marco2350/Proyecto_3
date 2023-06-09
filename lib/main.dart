import 'package:checkmate/src/pages/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'src/pages/calendar.dart';
import 'src/pages/reminder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: efigie(),);
  }
}

class efigie extends StatefulWidget {
  const efigie ({Key? key}) : super(key: key);

  @override
  State<efigie> createState() => _efigieState();
}

class _efigieState extends State<efigie> {
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 6)).then((value) {
      Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (ctx)=> ReminderApp())); }
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage("assets/ef.png"),width: 300,
              ),
               SizedBox(
                height:40
                ),
                  SpinKitThreeBounce(
                  color: Colors.green,
                  size: 50.0,
                  )
          ],
        ),
      ),
    );;
  }
}

void main2() => runApp(ReminderApp());

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Check Mate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderList(title: 'Pending Tasks'),
      onGenerateRoute: (RouteSettings settings){
        switch(settings.name){
          case '/home':
            return MaterialPageRoute(builder: (context) => ReminderApp());
          case '/calendar':
            return MaterialPageRoute(builder: (context) => Calendar(reminders: [],));
        }
      },
    );
  }
}



class ReminderList extends StatefulWidget {
  ReminderList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ReminderListState createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  List<Reminder> _reminders = [];
  List<bool> isChecked = [];
  String searchText = '';
  bool isSearching = false;
  

  void _addReminder(String title, String description, DateTime date) {
    setState(() {
      _reminders.add(Reminder(title, description, date));
    });
  }

  @override
  Widget build(BuildContext context) {
    
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(        
        title: isSearching
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              )
            : Text('Check Mate'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchText = '';
                }
                isSearching = !isSearching;
              });
            },
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Calendar(
                    reminders: _reminders,
                  ),
                ),
              );
            },
              icon: Icon(Icons.calendar_month)),
        ]
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          if (reminder.title.toLowerCase().contains(searchText.toLowerCase()) ||
              reminder.description
                  .toLowerCase()
                  .contains(searchText.toLowerCase())) {
          bool check = false;
          isChecked.add(check);

          Text titleDim = Text(
              '${reminder.title}',
              style: TextStyle(
                  fontWeight:
                      isChecked[index] ? FontWeight.normal : FontWeight.bold,
                  decoration: isChecked[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            );
            Text subtitleDim = Text(
              '${reminder.description}  -  ${isChecked[index]? 'Done':'In Progress'}',
              style: TextStyle(
                  fontWeight:
                      isChecked[index] ? FontWeight.normal : FontWeight.bold,
                  decoration: isChecked[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            );

          return Card(
            elevation: 2.0,
            child: ListTile(
              title: titleDim,
              subtitle: subtitleDim,
              leading: Checkbox(
                fillColor: MaterialStateProperty.resolveWith(getColor),
                value: isChecked[index],
                onChanged: (value) {
                  setState(() {
                    isChecked[index] = value!;
                  });
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _reminders.removeAt(index);
                  });
                },
              ),
            ),
          );
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ReminderDialog(
                onAddReminder: (title, description, date) {
                  _addReminder(title, description, date);
                  Navigator.pop(context);
                },
              ),
            );
        },
        tooltip: 'New Reminder',
        child: Icon(Icons.add),
      ),
    );
  }
}


class ReminderDialog extends StatefulWidget {
  final Function(String, String, DateTime) onAddReminder;

  ReminderDialog({required this.onAddReminder});

  @override
  _ReminderDialogState createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add a new reminder"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Title",
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "Description",
            ),
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (selectedDate != null && selectedDate != _selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                  _dateController.text =
                      DateFormat('MMM d, yyyy').format(_selectedDate);
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Date",
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("ADD"),
          onPressed: () {
            widget.onAddReminder(
              _titleController.text,
              _descriptionController.text,
              _selectedDate,
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
