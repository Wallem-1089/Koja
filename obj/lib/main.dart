/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;*/
//import 'dart:io';
//import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_math_fork/flutter_math.dart';


void main() => runApp(MaterialApp(
  home:HomePage(),
));

//class to create page 1 or screen 1
class HomePage extends StatelessWidget{
//  const HomePage({super.key});;u

  @override
  Widget build(BuildContext context){
    return Scaffold(
    /*need to add more things to the appbar */
    appBar: AppBar(
      title: Text("HomePage",
        style:TextStyle(
          fontSize: 15.0,
        ),  
        ),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
      /*floatingActionButton:FloatingActionButton(
        onPressed: null,
        child: Text("click"),)*/
    ),
    body: Center(
      child: Image.asset('assets/quotes.webp'),
    ),
   
    floatingActionButton: FloatingActionButton(
      onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> SecondPage()),); },
      backgroundColor: Colors.blueGrey,
      child: Text("Next")
    )
  );
}
}
class SecondPage extends StatefulWidget {

  @override
  _MySecondPageState createState() => _MySecondPageState();
}

class _MySecondPageState extends State<SecondPage> {
/// SUBJECT & YEAR OPTIONS
  List<String> subjectOptions = ["ENS211", "PRE211", "CPE481", "CPE461"];
  List<String> yearOptions = ["2020", "2021", "2022", "2023", "2024"];

  /// 4 SUBJECT SLOTS (Subject + Year)
  List<Map<String, String?>> selectedSubjectsData = [
    {"subject": null, "year": null},
    {"subject": null, "year": null},
    {"subject": null, "year": null},
    {"subject": null, "year": null},
  ];

  String selectedDuration = "30 Minutes";
  String selectedExamMode = "Mock"; // new

  /// BUILD FINAL SUBJECT LIST (e.g. CPE461_2022)
  List<String> getSelectedSubjects() {
    return selectedSubjectsData
        .where((item) => item["subject"] != null && item["year"] != null)
        .map((item) => "${item["subject"]}_${item["year"]}")
        .toList();
  }

  int getDurationInSeconds() {
    if (selectedDuration == "30 Minutes") return 1800;
    if (selectedDuration == "45 Minutes") return 2700;
    return 3600;
  }

  List<String> getAvailableSubjects(int currentIndex) {

  /// Get all selected subjects except current slot
  List<String> selected = selectedSubjectsData
      .asMap()
      .entries
      .where((entry) =>
          entry.key != currentIndex &&
          entry.value["subject"] != null)
      .map((entry) => entry.value["subject"]!)
      .toList();

  /// Return subjects not already selected
  return subjectOptions.where((subj) => !selected.contains(subj)).toList();
}


  /// SUBJECT CARD WIDGET
  Widget subjectSelector(int index) {

  List<String> availableSubjects = getAvailableSubjects(index);

  return Card(
    elevation: 3,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [

          Text(
            "Subject ${index + 1}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          /// SUBJECT DROPDOWN (NO DUPLICATES)
          DropdownButton<String>(
            value: selectedSubjectsData[index]["subject"],
            hint: Text("Select Subject"),
            isExpanded: true,

            items: [

              /// CLEAR OPTION
              DropdownMenuItem(
                value: null,
                child: Text("None"),
              ),

              /// FILTERED SUBJECTS
              ...availableSubjects.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ],

            onChanged: (value) {
              setState(() {
                selectedSubjectsData[index]["subject"] = value;

                /// reset year if cleared
                if (value == null) {
                  selectedSubjectsData[index]["year"] = null;
                }
              });
            },
          ),

          SizedBox(height: 10),

          /// YEAR DROPDOWN
          DropdownButton<String>(
            value: selectedSubjectsData[index]["year"],
            hint: Text("Select Year"),
            isExpanded: true,

            items: yearOptions.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),

            onChanged: selectedSubjectsData[index]["subject"] == null
                ? null
                : (value) {
                    setState(() {
                      selectedSubjectsData[index]["year"] = value;
                    });
                  },
          ),
        ],
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Pick Your Subjects"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),

      body: Row(
        children: [

          /// LEFT SIDE — SUBJECT SELECTORS (2x2 GRID)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [

                  /// ROW 1
                  Row(
                    children: [
                      Expanded(child: subjectSelector(0)),
                      SizedBox(width: 10),
                      Expanded(child: subjectSelector(1)),
                    ],
                  ),

                  SizedBox(height: 15),

                  /// ROW 2
                  Row(
                    children: [
                      Expanded(child: subjectSelector(2)),
                      SizedBox(width: 10),
                      Expanded(child: subjectSelector(3)),
                    ],
                  ),

                ],
              ),
            ),
          ),

          VerticalDivider(),

          /// RIGHT SIDE — DURATION
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(
                    "Select Exam Duration",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  DropdownButton<String>(
                    value: selectedDuration,
                    isExpanded: true,
                    items: [
                      "30 Minutes",
                      "45 Minutes",
                      "60 Minutes"
                    ].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDuration = value!;
                      });
                    },
                  ),
                  SizedBox(height: 30),

                /// ✅ NEW: EXAM MODE DROPDOWN
                Text(
                  "Select Exam Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                 SizedBox(height: 20),

              DropdownButton<String>(
                value: selectedExamMode,
                isExpanded: true,
                items: ["Mock", "Exam"]
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExamMode = value!;
                  });
                },
              ),
                ],
              ),
            ),
          ),
        ],
      ),
      

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          List<String> selectedSubjects = getSelectedSubjects();

          if (selectedSubjects.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please select at least one subject + year"),
              ),
            );
            return;
          }

          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThirdPage(
                examDuration: getDurationInSeconds(),
                selectedSubjects: selectedSubjects,
              ),
            ),
          );*/
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThirdPage(
              examDuration: getDurationInSeconds(),
              selectedSubjects: selectedSubjects,
              examMode: selectedExamMode, // ✅ NEW
    ),
  ),
);

        },

        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {

  final int examDuration;
  final List<String> selectedSubjects;
  final String examMode; // ✅ NEW

  ThirdPage({
    required this.examDuration,
    required this.selectedSubjects,
    required this.examMode,
  });

  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}

class _MyThirdPageState extends State<ThirdPage> {

  late List<String> jsonFiles;
  late List<String> subjects;

  Map<int, List<Map<String, dynamic>>> subjectQuestions = {};
  Map<int, Map<int, int>> subjectAnswers = {};

  int currentSubject = 0;
  int currentQuestionIndex = 0;

  late int remainingSeconds;
  Timer? countdownTimer;

  bool isLoading = true; //  FIX LOADING BUG

  @override
  void initState() {

    super.initState();

    remainingSeconds = widget.examDuration;

    /// SUBJECTS FROM SCREEN 2
    subjects = widget.selectedSubjects;

    /// JSON FILE PATHS
    jsonFiles = subjects.map((subject) {
      return "assets/$subject.json";
    }).toList();

    loadQuestions();
    startTimer();
  }

  ///  FAST JSON LOADING
  Future<void> loadQuestions() async {

    try {

      final rawFiles = await Future.wait(
        jsonFiles.map((file) => rootBundle.loadString(file)),
      );

      for (int i = 0; i < rawFiles.length; i++) {

        final List data = jsonDecode(rawFiles[i]);

        subjectQuestions[i] = data.map((q) {
          return {
            "question": q["question"],
            "options": List<String>.from(q["options"]),
            "answerIndex": q["answerIndex"],
          };
        }).toList();

        subjectAnswers[i] = {};
      }

    } catch (e) {
      print("JSON LOAD ERROR: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false; //  stop loader
      });
    }
  }

  Future<void> confirmExit() async {

  bool? shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must choose

    builder: (context) {
      return AlertDialog(
        title: Text("Exit Quiz"),
        content: Text("Are you sure you want to exit? Your progress will be lost."),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // ❌ Stay
            },
            child: Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // ✅ Exit
            },
            child: Text(
              "Exit",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  /// If user confirmed exit
  if (shouldExit == true) {

    countdownTimer?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }
}


  /// TIMER (OPTIMIZED)
  void startTimer() {

    countdownTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {

        if (remainingSeconds <= 0) {
          timer.cancel();
          submitQuiz();
          return;
        }

        remainingSeconds--;

        if (mounted) setState(() {});
      },
    );
  }

  String formatTime(int seconds) {

    int minutes = seconds ~/ 60;
    int secs = seconds % 60;

    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  void nextQuestion() {

    var questions = subjectQuestions[currentSubject];

    if (questions == null) return;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {

    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void changeSubject(int index) {

    setState(() {
      currentSubject = index;
      currentQuestionIndex = 0;
    });
  }
///Math Render Function
  Widget buildContent(String text) {

  /// Detect LaTeX ($...$)
  final regex = RegExp(r'\$(.*?)\$');

  if (!regex.hasMatch(text)) {
    return Text(
      text,
      style: TextStyle(fontSize: 22),
    );
  }

  /// Split text + math parts
  List<InlineSpan> spans = [];

  int lastIndex = 0;

  for (final match in regex.allMatches(text)) {

    /// Normal text before math
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
      );
    }

    /// Math part
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle: TextStyle(fontSize: 22),
        ),
      ),
    );

    lastIndex = match.end;
  }

  /// Remaining text
  if (lastIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: Colors.black, fontSize: 22),
      ),
    );
  }

  return RichText(
    text: TextSpan(children: spans),
  );
}


  void submitQuiz() {

    countdownTimer?.cancel();

    int score = 0;
    int total = 0;

    subjectQuestions.forEach((subjectIndex, questions) {

      for (int i = 0; i < questions.length; i++) {

        total++;

        if (subjectAnswers[subjectIndex]?[i] ==
            questions[i]["answerIndex"]) {
          score++;
        }
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(
              score: score,
              total: total,
              examMode: widget.examMode,
              subjectQuestions: subjectQuestions,
),

      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// FIX: Proper loading check
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("CBT App")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// EXTRA SAFETY
    if (subjectQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("No questions loaded")),
      );
    }

    var questions = subjectQuestions[currentSubject]!;
    var currentQuestion = questions[currentQuestionIndex];
    /*List options = currentQuestion["options"];*/
    List<String> options = List<String>.from(currentQuestion["options"]);

    return WillPopScope(
      onWillPop: () async {
        await confirmExit();
        return false; // block default back
      },
    child: Scaffold(

      /*appBar: AppBar(
        title: Text("CBT App"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),*/
      appBar: AppBar(
        title: Text("CBT App"),
        automaticallyImplyLeading: false, // ❌ removes default back arrow

        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: confirmExit, // ✅ use dialog
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          /// SUBJECT SWITCHER
          Padding(
            padding: EdgeInsets.all(8),

            child: SegmentedButton<int>(
              segments: List.generate(
                subjects.length,
                (index) => ButtonSegment(
                  value: index,
                  label: Text(subjects[index]),
                ),
              ),
              selected: {currentSubject},
              onSelectionChanged: (value) {
                changeSubject(value.first);
              },
            ),
          ),

          /// QUESTION AREA
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Question ${currentQuestionIndex + 1}/${questions.length}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 15),

                  buildContent(currentQuestion["question"]),

                  SizedBox(height: 15),

                  ...List.generate(options.length, (index) {

                    return RadioListTile<int>(
                      title: buildContent(options[index]),
                      value: index,
                      groupValue:
                          subjectAnswers[currentSubject]?[currentQuestionIndex],
                      onChanged: (value) {
                        setState(() {
                          subjectAnswers[currentSubject]?[currentQuestionIndex] =
                              value!;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          /// BUTTONS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        currentQuestionIndex == 0 ? null : previousQuestion,
                    child: Text("Previous"),
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        currentQuestionIndex == questions.length - 1
                            ? null
                            : nextQuestion,
                    child: Text("Next"),
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: submitQuiz,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black12),
                    child: Text("Submit"),
                  ),
                ),
              ],
            ),
          ),

          /// NAVIGATION GRID (UNCHANGED)
          Container(
            height: 100,
            padding: EdgeInsets.all(8),

            child: GridView.builder(
              itemCount: questions.length,

              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 20,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),

              itemBuilder: (context, index) {

                bool isAnswered =
                    subjectAnswers[currentSubject]!.containsKey(index);

                bool isCurrent =
                    index == currentQuestionIndex;

                return GestureDetector(

                  onTap: () {
                    setState(() {
                      currentQuestionIndex = index;
                    });
                  },

                  child: Container(
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.blue
                          : isAnswered
                              ? Colors.green
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),

                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCurrent || isAnswered
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
    );
  }
}

//modify this code to include the corrections to make the code run faster

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final String examMode;
  final Map<int, List<Map<String, dynamic>>> subjectQuestions;

  ResultPage({
    required this.score,
    required this.total,
    required this.examMode,
    required this.subjectQuestions,
  });

//Math Render Function
Widget buildContent(String text) {

  final regex = RegExp(r'\$(.*?)\$');

  if (!regex.hasMatch(text)) {
    return Text(
      text,
      style: TextStyle(fontSize: 16),
    );
  }

  List<InlineSpan> spans = [];
  int lastIndex = 0;

  for (final match in regex.allMatches(text)) {

    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    }

    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  return RichText(
    text: TextSpan(children: spans),
  );
}

  @override
Widget build(BuildContext context) {
  double percentage = (score / total) * 100;

  return Scaffold(
    appBar: AppBar(title: Text("Exam Result")),

    body: Column(
      children: [

        /// RESULT SUMMARY
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  "Your Score",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Text(
                  "$score / $total",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 28,
                    color: percentage >= 50 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// ✅ MOCK MODE REVIEW
        if (examMode == "Mock")
          Expanded(
            flex: 3,
            child: ListView(
              padding: EdgeInsets.all(10),
              children: subjectQuestions.entries.expand((entry) {
                return entry.value.map((q) {
                  return Card(
                    //style: TextStyle(color: Colors.green),
                    child: ListTile(
                      title: buildContent(q["question"]),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(height: 5),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Correct Answer: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: buildContent(
                                  q["options"][q["answerIndex"]],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ),
                  );
                });
              }).toList(),
            ),
          ),

        /// BUTTON
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                (route) => false,
              );
            },
            child: Text("Back to Home Page"),
          ),
        ),
      ],
    ),
  );
}
}
//modify this code to include the changes given in the last prompt result