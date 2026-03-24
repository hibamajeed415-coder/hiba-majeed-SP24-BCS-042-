import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(FocusNestApp());
}

//======================= MAIN APP =======================
class FocusNestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusNest Ultimate',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color(0xFFF5F0E6),
        primaryColor: Color(0xFFDAB894),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFC9B79C),
        ),
      ),
      home: StartScreen(),
    );
  }
}

//======================= START SCREEN =======================
class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _decorController;

  @override
  void initState() {
    super.initState();
    _iconController =
    AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..repeat(reverse: true);
    _decorController =
    AnimationController(vsync: this, duration: Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decorations (icons fallback if images missing)
          Positioned(
            top: 50,
            left: 30,
            child: FadeTransition(
              opacity:
              Tween(begin: 0.3, end: 0.8).animate(_decorController),
              child: Icon(Icons.star, size: 50, color: Colors.yellow),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 40,
            child: FadeTransition(
              opacity:
              Tween(begin: 0.3, end: 0.7).animate(_decorController),
              child: Icon(Icons.star, size: 70, color: Colors.amber),
            ),
          ),
          // Main UI
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F0E6), Color(0xFFE8D9C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.2)
                        .animate(_iconController),
                    child: Icon(Icons.auto_stories,
                        size: 150, color: Color(0xFFDAB894)),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "FocusNest Ultimate 🌸",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E3C)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your professional study companion",
                    style: TextStyle(fontSize: 16, color: Color(0xFF8B5E3C)),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDAB894),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => HomePage()));
                    },
                    child: Text("Start"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//======================= HOME PAGE =======================
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingBookController;

  final List<String> subjects = [
    "DA",
    "OS",
    "Mobile Development",
    "Computer Organization",
    "Assembly Language",
    "Statistics",
    "Web App"
  ];

  final Map<String, List<String>> chapters = {
    "DA": ["Chapter 1", "Chapter 2", "Chapter 3"],
    "OS": ["Processes", "Threads", "Memory"],
    "Mobile Development": ["Flutter Basics", "Widgets", "State"],
    "Computer Organization": ["CPU", "Registers"],
    "Assembly Language": ["Instructions", "Loops"],
    "Statistics": ["Mean", "Probability"],
    "Web App": ["HTML", "CSS", "JS"],
  };

  int streak = 0;
  int dailyGoal = 3;

  final Map<String, String> timetable = {
    "09:00": "DA",
    "10:00": "OS",
    "11:00": "Mobile Development",
    "12:00": "Computer Organization",
    "13:00": "Assembly Language",
    "14:00": "Statistics",
    "15:00": "Web App",
  };

  String currentClass = "";

  @override
  void initState() {
    super.initState();
    _floatingBookController =
    AnimationController(vsync: this, duration: Duration(seconds: 3))
      ..repeat(reverse: true);

    Timer.periodic(Duration(seconds: 30), (_) => checkTime());
  }

  void checkTime() {
    String now =
        "${TimeOfDay.now().hour.toString().padLeft(2, '0')}:00";
    if (timetable.containsKey(now)) {
      setState(() {
        currentClass = timetable[now]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Class Starting: $currentClass ⏰"),
            backgroundColor: Color(0xFFDAB894)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      StudyTab(subjects: subjects, chapters: chapters, onComplete: () {
        setState(() => streak++);
      }),
      TimetableTab(timetable: timetable, currentClass: currentClass),
      BooksTab(subjects: subjects, chapters: chapters),
      ProgressTab(streak: streak, dailyGoal: dailyGoal),
      SettingsTab(onReset: () {
        setState(() {
          streak = 0;
        });
      }),
    ];

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: pages[_selectedIndex],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.2)
                  .animate(CurvedAnimation(parent: _floatingBookController, curve: Curves.easeInOut)),
              child: Icon(Icons.auto_stories, size: 50, color: Color(0xFFC9B79C)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF8B5E3C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            _selectedIndex = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Study"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Time"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Books"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

//======================= STUDY TAB =======================
class StudyTab extends StatefulWidget {
  final List<String> subjects;
  final Map<String, List<String>> chapters;
  final VoidCallback onComplete;

  StudyTab(
      {required this.subjects, required this.chapters, required this.onComplete});

  @override
  _StudyTabState createState() => _StudyTabState();
}

class _StudyTabState extends State<StudyTab> with TickerProviderStateMixin {
  String selected = "DA";
  int timeLeft = 0;
  Timer? timer;
  bool running = false;

  String quote = "";
  List<String> quotes = [
    "Focus on your goals 🌸",
    "Every minute counts ⏳",
    "You can do it! 💪",
    "Keep studying and shine ✨",
    "Small steps lead to success 🌟",
  ];

  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();
    _circleController =
    AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..repeat(reverse: true);
    _randomQuote();
  }

  void _randomQuote() {
    final rnd = Random();
    setState(() {
      quote = quotes[rnd.nextInt(quotes.length)];
    });
  }

  void start(int min) {
    if (!running) {
      if (timeLeft == 0) timeLeft = min * 60;
      _randomQuote();
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        if (timeLeft > 0) {
          setState(() => timeLeft--);
        } else {
          t.cancel();
          running = false;
          widget.onComplete();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Session Completed for $selected 🎉"),
              backgroundColor: Color(0xFFDAB894)));
        }
      });
      running = true;
    }
  }

  void pause() {
    timer?.cancel();
    running = false;
  }

  void resume() {
    if (!running && timeLeft > 0) {
      timer = Timer.periodic(Duration(seconds: 1), (t) {
        if (timeLeft > 0) {
          setState(() => timeLeft--);
        } else {
          t.cancel();
          running = false;
          widget.onComplete();
        }
      });
      running = true;
    }
  }

  String formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
        LinearGradient(colors: [Color(0xFFF5F0E6), Color(0xFFE8D9C8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _circleController,
                builder: (context, child) {
                  return Container(
                    width: 150 + _circleController.value * 20,
                    height: 150 + _circleController.value * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC9B79C).withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        formatTime(timeLeft),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Text(quote,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selected,
                items: widget.subjects
                    .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                    .toList(),
                onChanged: (val) => setState(() => selected = val!),
              ),
              SizedBox(height: 10),
              Text("Chapters:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.chapters[selected]!
                  .map((chap) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(Icons.bookmark, color: Color(0xFFDAB894)),
                  title: Text(chap),
                ),
              ))
                  .toList(),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(onPressed: () => start(1), child: Text("Start 1m")),
                  ElevatedButton(onPressed: () => start(2), child: Text("Start 2m")),
                  ElevatedButton(onPressed: () => start(5), child: Text("Start 5m")),
                  ElevatedButton(onPressed: () => start(10), child: Text("Start 10m")),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(onPressed: pause, child: Text("Pause")),
                  ElevatedButton(onPressed: resume, child: Text("Resume")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//======================= TIMETABLE TAB =======================
class TimetableTab extends StatelessWidget {
  final Map<String, String> timetable;
  final String currentClass;

  TimetableTab({required this.timetable, required this.currentClass});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: timetable.entries.map((e) {
        bool highlight = e.value == currentClass;
        return AnimatedContainer(
          duration: Duration(seconds: 1),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: highlight ? Color(0xFFDAB894).withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 3))
            ],
          ),
          child: ListTile(
            title: Text("${e.key} - ${e.value}"),
            leading: Icon(Icons.schedule, color: Color(0xFFDAB894)),
          ),
        );
      }).toList(),
    );
  }
}

//======================= BOOKS TAB =======================
class BooksTab extends StatelessWidget {
  final List<String> subjects;
  final Map<String, List<String>> chapters;
  BooksTab({required this.subjects, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: subjects.map((sub) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            leading: Icon(Icons.menu_book, color: Color(0xFFDAB894)),
            title: Text(sub),
            children: chapters[sub]!
                .map((ch) => ListTile(
              leading: Icon(Icons.bookmark, color: Color(0xFFC9B79C)),
              title: Text(ch),
            ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}

//======================= PROGRESS TAB =======================
class ProgressTab extends StatelessWidget {
  final int streak;
  final int dailyGoal;
  ProgressTab({required this.streak, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    double progress = streak / dailyGoal;
    if (progress > 1) progress = 1;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Daily Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  color: Color(0xFF8B5E3C),
                  backgroundColor: Color(0xFFDAB894).withOpacity(0.3),
                ),
              ),
              Text("$streak / $dailyGoal", style: TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

//======================= SETTINGS TAB =======================
class SettingsTab extends StatelessWidget {
  final VoidCallback onReset;
  SettingsTab({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onReset,
        child: Text("Reset Streak & Progress"),
      ),
    );
  }
}