//import 'package:flutter/material.dart';//
//import 'dart:io';
//import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'result_model.dart';
import 'isar_service.dart';


late Isar isar; // global instance

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  isar = await Isar.open(
    [
      ResultModelSchema,
      /*SubjectPerformanceSchema,*/
    ],
    directory: dir.path,
  );

  runApp(MaterialApp(
    home: HomePage(),
  ));
}
class HomePage extends StatelessWidget{

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
      actions: [
    IconButton(
      icon: Icon(Icons.history),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultHistoryPage()),
        );
      },
    )
  ],
      centerTitle: true,
      backgroundColor: Colors.blueGrey,  
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
  List<String> subjectOptions = ["USEOFENGLISH", "GENERALPAPER", "CPE481", "CPE461"];
  List<String> yearOptions = ["2021", "2022", "2023", "2024", "2025", "PRACTICE"];

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
    if (selectedDuration == "15 Minutes") return 900;
    if (selectedDuration == "45 Minutes") return 2700;
    if (selectedDuration == "2 Hours") return 7200;
    return 3600;
  }

  /*List<String> getAvailableSubjects(int currentIndex) {

  /// Get all selected subjects except current slot
  List<String> selected = selectedSubjectsData
      .asMap()
      .entries
      .where((entry) =>
          entry.key != currentIndex &&
          entry.value["subject"] != null)
      .map((entry) => entry.value["subject"]!
      )
      .toList();

  /// Return subjects not already selected
  return subjectOptions.where((subj) => !selected.contains(subj)).toList();
}*/


  /// SUBJECT CARD WIDGET
  Widget subjectSelector(int index) {

  //List<String> availableSubjects = getAvailableSubjects(index);

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

              DropdownMenuItem<String>(
                value: null,
                child: Text("None"),
              ),

              ...subjectOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ],

            onChanged: (value) {
              setState(() {
                selectedSubjectsData[index]["subject"] = value;

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

  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 700;

  return Scaffold(

      appBar: AppBar(
        title: Text("Pick Your Subjects"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),

      body: isMobile
    ? SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [

              /// SUBJECTS
              subjectSelector(0),
              SizedBox(height: 12),

              subjectSelector(1),
              SizedBox(height: 12),

              subjectSelector(2),
              SizedBox(height: 12),

              subjectSelector(3),

              SizedBox(height: 25),

              /// DURATION
              Text(
                "Select Exam Duration",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              DropdownButton<String>(
                value: selectedDuration,
                isExpanded: true,
                items: [
                  "15 Minutes",
                  "30 Minutes",
                  "45 Minutes",
                  "60 Minutes",
                  "2 Hours"
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

              SizedBox(height: 25),

              /// EXAM MODE
              Text(
                "Select Exam Mode",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              DropdownButton<String>(
                value: selectedExamMode,
                isExpanded: true,
                items: ["Mock", "Exam", "Study"]
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
      )

    : Row(
        children: [

          /// LEFT SIDE — SUBJECT SELECTORS
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(child: subjectSelector(0)),
                      SizedBox(width: 10),
                      Expanded(child: subjectSelector(1)),
                    ],
                  ),

                  SizedBox(height: 15),

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

          /// RIGHT SIDE
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  DropdownButton<String>(
                    value: selectedDuration,
                    isExpanded: true,
                    items: [
                      "15 Minutes",
                      "30 Minutes",
                      "45 Minutes",
                      "60 Minutes",
                      "2 Hours"
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

                  Text(
                    "Select Exam Mode",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  DropdownButton<String>(
                    value: selectedExamMode,
                    isExpanded: true,
                    items: ["Mock", "Exam", "Study"]
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
          Set<String> combinations = {};

          for (var item in selectedSubjectsData) {

            if (item["subject"] != null && item["year"] != null) {

              String combo = "${item["subject"]}_${item["year"]}";

              if (combinations.contains(combo)) {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Duplicate subject-year combination detected",
                    ),
                  ),
                );

                return;
              }

              combinations.add(combo);
            }
          }

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
              examMode: selectedExamMode, //  NEW
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
  final String examMode; //  NEW
  final Map<int, List<Map<String, dynamic>>>? preloadedQuestions;// new

  ThirdPage({
    required this.examDuration,
    required this.selectedSubjects,
    required this.examMode,
     this.preloadedQuestions, // NEW
  });

  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}

class _MyThirdPageState extends State<ThirdPage> {

  late List<String> jsonFiles;
  late List<String> subjects;

  Map<int, List<Map<String, dynamic>>> subjectQuestions = {};
  Map<int, Map<int, int>> subjectAnswers = {};
  Map<int, Map<int, bool>> checkedQuestions = {};// new 2

  int currentSubject = 0;
  int currentQuestionIndex = 0;

  late int remainingSeconds;
  Timer? countdownTimer;

  bool isLoading = true; //  FIX LOADING BUG
  bool isSubmitting = false;

  final ScrollController _scrollController = ScrollController(); // scroller for study mode


  @override
  void initState() {

    super.initState();

    remainingSeconds = widget.examDuration;

    /// SUBJECTS FROM SCREEN 2
    subjects = widget.selectedSubjects;

    /// IF RETRY MODE → USE PRELOADED QUESTIONS
  if (widget.preloadedQuestions != null) {
    subjectQuestions = widget.preloadedQuestions!;

    /// initialize empty answers
    subjectQuestions.forEach((key, value) {
      subjectAnswers[key] = {};
      checkedQuestions[key] = {};
    });

    isLoading = false;
  } else {
    /// JSON FILE PATHS
    jsonFiles = subjects.map((subject) {
      return "assets/post_utme/uniben/$subject.json";
    }).toList();

    loadQuestions();
  }
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
            "options": q["options"],
            "answerIndex": q["answerIndex"],
            "explanation": q["explanation"] ?? "",
            "image": q["image"] ?? "", // //  NEW
          };
        }).toList();

        subjectAnswers[i] = {};
        checkedQuestions[i] = {};// new 2
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
              Navigator.pop(context, true); //  Exit
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

Future<void> confirmSubmit() async {
  ///  Block if already submitting
  if (isSubmitting) return;

  bool? shouldSubmit = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must choose

    builder: (context) {
      return AlertDialog(
        title: Text("Submit Exam"),
        content: Text("Are you sure you want to submit your answers?"),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false); //  Cancel
            },
            child: Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context, true); //  Confirm
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  /// If user confirmed → submit
  if (shouldSubmit == true) {
    submitQuiz();
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

      /// ✅ 5-minute warning (300 seconds)
      if (remainingSeconds == 300) {
        showFiveMinuteWarning();
      }

      remainingSeconds--;

      if (mounted) setState(() {});
    },
  );
}
  void showFiveMinuteWarning() {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("5 minutes left!"),
      duration: Duration(seconds: 5),
    ),
  );
}



  String formatTime(int seconds) {

  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;

  /// ✅ If 1 hour or more → HH:MM:SS
  if (hours > 0) {
    return "${hours.toString().padLeft(2, '0')}:"
           "${minutes.toString().padLeft(2, '0')}:"
           "${secs.toString().padLeft(2, '0')}";
  }

  /// ✅ If less than 1 hour → MM:SS
  return "${minutes.toString().padLeft(2, '0')}:"
         "${secs.toString().padLeft(2, '0')}";
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
    if (!subjectQuestions.containsKey(index)) return;
    setState(() {
      currentSubject = index;
      currentQuestionIndex = 0;
    });
  }
  
  Future<void> saveResult(
  int score,
  int total,
  List<String> subjects,
  String mode,
  int duration,
  int timeSpent,
  Map<int, int> subjectScores,
  Map<int, int> subjectTotals,
) async {
  final result = ResultModel()
    ..score = score
    ..total = total
    ..subjects = subjects
    ..mode = mode
    ..duration = duration
    ..timeSpent = timeSpent
    ..date = DateTime.now()
    ..percentage = (score / total) * 100
    ..performances = [];

  for (int i = 0; i < subjects.length; i++) {
    result.performances.add(
      SubjectPerformance()
        ..subject = subjects[i]
        ..score = subjectScores[i] ?? 0
        ..total = subjectTotals[i] ?? 0,
    );
  }

  await isar.writeTxn(() async {
    await isar.resultModels.put(result);
  });
}
///Math Render Function
 Widget buildContent(String text) {

  double screenWidth = MediaQuery.of(context).size.width;

  double fontSize = screenWidth < 400
      ? 16
      : screenWidth < 700
          ? 19
          : 22;
    

  /// Detect LaTeX ($...$)
  final regex = RegExp(r'\$(.*?)\$');

  /// Detect Underline (<u>...</u>)
  final underlineRegex = RegExp(r'<u>(.*?)<\/u>');

  /// If no math AND no underline → normal text
  if (!regex.hasMatch(text) && !underlineRegex.hasMatch(text)) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize),
    );
  }

  /// Split text + math + underline parts
  List<InlineSpan> spans = [];

  int lastIndex = 0;

  /// Combined regex
  final combinedRegex = RegExp(r'\$(.*?)\$|<u>(.*?)<\/u>');

  for (final match in combinedRegex.allMatches(text)) {

    /// Normal text before special part
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
          ),
        ),
      );
    }

    /// Math part
    if (match.group(1) != null) {

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            match.group(1)!,
            textStyle: TextStyle(fontSize: fontSize),
          ),
        ),
      );
    }

    /// Underline part
    else if (match.group(2) != null) {

      spans.add(
        TextSpan(
          text: match.group(2)!,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    lastIndex = match.end;
  }

  /// Remaining text
  if (lastIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      ),
    );
  }

  return LayoutBuilder(
  builder: (context, constraints) {
    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(children: spans),
    );
  },
);
}
  Widget optionWidget(dynamic option) {

  /// OLD FORMAT (STRING)
  if (option is String) {
    return buildContent(option);
  }

  /// NEW FORMAT (MAP)
  if (option is Map<String, dynamic>) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TEXT
        if ((option["text"] ?? "").toString().isNotEmpty)
          buildContent(option["text"]),

        /// IMAGE
        if ((option["image"] ?? "").toString().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120),
              child: Image.asset(
                option["image"],
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  return Text("Invalid Option");
}

  void submitQuiz() async {
  if (isSubmitting) return;

  isSubmitting = true;

  countdownTimer?.cancel();

  int score = 0;
  int total = 0;
  int timeSpentSeconds = widget.examDuration - remainingSeconds;

  Map<int, int> subjectScores = {};
  Map<int, int> subjectTotals = {};

  subjectQuestions.forEach((subjectIndex, questions) {
    int subScore = 0;
    int subTotal = questions.length;

    for (int i = 0; i < questions.length; i++) {
      total++;

      if (subjectAnswers[subjectIndex]?[i] ==
          questions[i]["answerIndex"]) {
        score++;
        subScore++;
      }
    }

    subjectScores[subjectIndex] = subScore;
    subjectTotals[subjectIndex] = subTotal;
  });

  DateTime submissionTime = DateTime.now();

  /// ✅ STEP 3: CONVERT TO ISAR FORMAT
  List<SubjectPerformance> performances = [];

  for (int i = 0; i < subjects.length; i++) {
    performances.add(
      SubjectPerformance()
        ..subject = subjects[i]
        ..score = subjectScores[i] ?? 0
        ..total = subjectTotals[i] ?? 0,
    );
  }
  

  /// ✅ SAVE TO ISAR
  await saveResultToIsar(
    score: score,
    total: total,
    subjects: subjects,
    mode: widget.examMode,
    duration: widget.examDuration,
    timeSpent: timeSpentSeconds,
    date: submissionTime,
    performances: performances,
  );

  /// 👉 THEN NAVIGATE
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ResultPage(
        score: score,
        total: total,
        examMode: widget.examMode,
        subjectQuestions: subjectQuestions,
        subjectAnswers: subjectAnswers,
        submissionTime: submissionTime,
        timeSpentSeconds: timeSpentSeconds,
        totalDuration: widget.examDuration,
        subjectScores: subjectScores,
        subjectTotals: subjectTotals,
        subjects: subjects,
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
    List options = currentQuestion["options"];

    void selectOption(int index) {
  // Option Selection Function
  var questions = subjectQuestions[currentSubject];
  if (questions == null) return;

  var currentQuestion = questions[currentQuestionIndex];
  List options = currentQuestion["options"];

  /// Prevent crash if question has less than 4 options
  if (index >= options.length) return;

  setState(() {
    subjectAnswers[currentSubject]?[currentQuestionIndex] = index;
  });
}


    return WillPopScope(
      onWillPop: () async {
        await confirmExit();
        return false; // block default back
      },
    child: Focus(
    autofocus: true,
    onKeyEvent: (node, event) {

      if (event is KeyDownEvent) {

        final key = event.logicalKey;

        /// A B C D → Select options
        if (key == LogicalKeyboardKey.keyA) {
          selectOption(0);
        } else if (key == LogicalKeyboardKey.keyB) {
          selectOption(1);
        } else if (key == LogicalKeyboardKey.keyC) {
          selectOption(2);
        } else if (key == LogicalKeyboardKey.keyD) {
          selectOption(3);
        }

        /// Navigation
        else if (key == LogicalKeyboardKey.keyN) {
          nextQuestion();
        } else if (key == LogicalKeyboardKey.keyP) {
          previousQuestion();
        }

        /// Submit
        else if (key == LogicalKeyboardKey.keyS) {
          if (!isSubmitting) {
            confirmSubmit();
  }
        }
      }

      return KeyEventResult.handled;
    },
    child: Scaffold(

      appBar: AppBar(
        title: Text(
          widget.examMode == "Retry" ? "Retry Wrong Questions" : "CBT App",
        ),
        automaticallyImplyLeading: false, //  removes default back arrow

        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: confirmExit, //  use dialog
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
              segments: subjectQuestions.keys.map((index) {
                return ButtonSegment(
                  value: index,
                  label: Text(subjects[index]),
                );
              }).toList(),

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
              
              child: SingleChildScrollView(
              controller: _scrollController, // new
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [

                  Text(
                    "Question ${currentQuestionIndex + 1}/${questions.length}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  buildContent(currentQuestion["question"]),
                  if ((currentQuestion["image"] ?? "").toString().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: InteractiveViewer(
                                      child: Image.asset(currentQuestion["image"]),
                                    ),
                                  ),
                                );
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: Image.asset(
                                  currentQuestion["image"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),


                                          SizedBox(height: 8),

                                          ...List.generate(options.length, (index) {
                                            String optionLetter = ["A", "B", "C", "D"][index];
                                            return RadioListTile<int>(
                                              contentPadding: EdgeInsets.zero,
                                              title: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("$optionLetter. "),
                                                  Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ✅ HANDLE STRING FORMAT (OLD)
                              if (options[index] is String)
                                buildContent(options[index]),

                              /// ✅ HANDLE MAP FORMAT (NEW)
                              if (options[index] is Map) ...[

                                if ((options[index]["text"] ?? "").toString().isNotEmpty)
                                  buildContent(options[index]["text"]),

                                if ((options[index]["image"] ?? "").toString().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            child: InteractiveViewer(
                                              child: Image.asset(options[index]["image"]),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(maxHeight: 100),
                                        child: Image.asset(
                                          options[index]["image"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),

                        ],
                      ),
                      value: index,
                      groupValue: subjectAnswers[currentSubject]?[currentQuestionIndex],
                      onChanged: checkedQuestions[currentSubject]?[currentQuestionIndex] == true
                          ? null // disable if checked
                          : (value) {
                              setState(() {
                                subjectAnswers[currentSubject]?[currentQuestionIndex] = value!;
                              });
                            },
                    );
                  }),
                  /// ✅ STUDY MODE CHECK BUTTON
            if (widget.examMode == "Study")
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        checkedQuestions[currentSubject]?[currentQuestionIndex] = true;
                        checkedQuestions[currentSubject] ??= {}; // new
                      });
                    /// ✅ Smooth scroll after UI builds
                    Future.delayed(Duration(milliseconds: 100), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      }
                    });  
                    },
                    child: Text("Check"),
                  ),
              ),

            if (checkedQuestions[currentSubject]?[currentQuestionIndex] == true)
              Builder(
                builder: (_) {

                  int correctIndex = currentQuestion["answerIndex"];
                  int? userIndex =
                      subjectAnswers[currentSubject]?[currentQuestionIndex];

                  bool isCorrect = userIndex == correctIndex;

                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// USER ANSWER
                        Text(
                          "Your Answer:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        userIndex == null
                            ? Text("Not Answered", style: TextStyle(color: Colors.orange))
                            : optionWidget(currentQuestion["options"][userIndex]),

                        SizedBox(height: 5),

                        /// CORRECT ANSWER
                        Text(
                          "Correct Answer:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        optionWidget(currentQuestion["options"][correctIndex]),

                        SizedBox(height: 5),

                        /// STATUS
                        Text(
                          userIndex == null
                              ? "Not Attempted"
                              : isCorrect
                                  ? "Correct"
                                  : "Wrong",
                          style: TextStyle(
                            color: userIndex == null
                                ? Colors.orange
                                : isCorrect
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        /// EXPLANATION
                        if ((currentQuestion["explanation"] ?? "").toString().isNotEmpty) ...[
                          Text(
                            "Explanation:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),

                          SizedBox(height: 5),

                          buildContent(currentQuestion["explanation"]),
                          SizedBox(height: 40),
                        ],
                      ],
                    ),
                  );
                },
              ),
                            ],
                          ),
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
                    onPressed: confirmSubmit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black12),
                    child: isSubmitting
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ) : Text("Submit"),
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
              crossAxisCount:
                  MediaQuery.of(context).size.width < 700 ? 5 : 20,
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
    ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final String examMode;
  final Map<int, List<Map<String, dynamic>>> subjectQuestions;
  final Map<int, Map<int, int>> subjectAnswers; // NEW
  final DateTime submissionTime; //new
  final int timeSpentSeconds; // new
  final int totalDuration;
  final Map<int, int> subjectScores;
  final Map<int, int> subjectTotals;
  final List<String> subjects;

  ResultPage({
    required this.score,
    required this.total,
    required this.examMode,
    required this.subjectQuestions,
    required this.subjectAnswers, // NEW
    required this.submissionTime, // NEW
    required this.timeSpentSeconds,
    required this.totalDuration,
    ///  NEW
    required this.subjectScores,
    required this.subjectTotals,
    required this.subjects,
  });
String formatTimeSpent(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;

  if (hours > 0) {
    return "$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  } else {
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }
}

String formatSubmissionTime(DateTime time) {
  return "${time.day}/${time.month}/${time.year} "
         "${time.hour.toString().padLeft(2, '0')}:"
         "${time.minute.toString().padLeft(2, '0')}";
}

String formatSeconds(double seconds) {
  int mins = seconds ~/ 60;
  int secs = seconds.toInt() % 60;

  return "$mins:${secs.toString().padLeft(2, '0')}";
}

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
  /*return LayoutBuilder(
  builder: (context, constraints) {
    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(children: spans),
    );
  },
);*/
}
List<Map<String, dynamic>> getWrongQuestions() {
  List<Map<String, dynamic>> wrong = [];

  subjectQuestions.forEach((subjectIndex, questions) {
    for (int i = 0; i < questions.length; i++) {
      int correct = questions[i]["answerIndex"];
      int? user = subjectAnswers[subjectIndex]?[i];

      if (user != correct) {
        wrong.add({
          "subject": subjectIndex,
          "questionIndex": i,
          "data": questions[i],
        });
      }
    }
  });

  return wrong;
}
void retryWrongQuestions(BuildContext context) {
  if (examMode != "Mock" && examMode != "Study") return;

  Map<int, List<Map<String, dynamic>>> retryQuestions = {};

  subjectQuestions.forEach((subjectIndex, questions) {

    List<Map<String, dynamic>> wrongList = [];

    for (int i = 0; i < questions.length; i++) {

      int correct = questions[i]["answerIndex"];
      int? user = subjectAnswers[subjectIndex]?[i];

      if (user != correct) {
        wrongList.add(questions[i]);
      }
    }

    if (wrongList.isNotEmpty) {
      retryQuestions[subjectIndex] = wrongList;
    }
  });

  if (retryQuestions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No wrong questions to retry!")),
    );
    return;
  }
  int totalRetryQuestions = retryQuestions.values
    .fold(0, (sum, list) => sum + list.length);

  int retryDuration = (totalRetryQuestions * 30).clamp(60, 3600);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => ThirdPage(
        selectedSubjects: subjects,
        examMode: "Retry", // NEW MODE
        examDuration: retryDuration, // or shorter if you want
        preloadedQuestions: retryQuestions, //  IMPORTANT
      ),
    ),
  );
}
Widget optionsDisplay(dynamic option) {

  /// TEXT OPTION
  if (option is String) {
    return buildContent(option);
  }

  /// IMAGE OPTION
  if (option is Map && option["type"] == "image") {
    return Image.asset(
      option["value"],
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          "Image not found",
          style: TextStyle(color: Colors.red),
        );
      },
    );
  }

  /// TEXT (MAP FORMAT)
  if (option is Map && option["type"] == "text") {
    return buildContent(option["value"]);
  }

  return Text("Invalid option format");
}


  @override
Widget build(BuildContext context) {
  double percentage = (score / total) * 100;
  double avgTimePerQuestion = timeSpentSeconds / total; //new
  double efficiency = (timeSpentSeconds / totalDuration) * 100;

  return Scaffold(
    appBar: AppBar(title: Text("Exam Result"),),

    body: (examMode == "Mock" || examMode == "Study" || examMode == "Exam"  || examMode == "Retry")
    ? Stack(
        children: [

          /// SCROLLABLE CONTENT
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),

            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),

              child: IntrinsicHeight(
                child: Column(
                  children: [

                    /// RESULT SUMMARY
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            "Your Score",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 7),

                          Text(
                            "$score / $total",
                            style: TextStyle(
                              fontSize:
                                MediaQuery.of(context).size.width < 700 ? 28 : 40,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 7),

                          Text(
                            "${percentage.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 28,
                              color: percentage >= 50
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          SizedBox(height: 5),

                          Wrap(
                            spacing: 16,
                            runSpacing: 8,

                            children: [

                              Text(
                                "Submitted: ${formatSubmissionTime(submissionTime)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),

                              Text(
                                "Time: ${formatTimeSpent(timeSpentSeconds)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),

                              Text(
                                "Avg/Q: ${formatSeconds(avgTimePerQuestion)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),

                              Text(
                                "Efficiency: ${efficiency.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: efficiency < 50
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// PERFORMANCE PER SUBJECT
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(height: 2),

                          Wrap(
                            spacing: 12,
                            runSpacing: 8,

                            children: List.generate(
                              subjects.length,
                              (index) {

                                int subScore =
                                    subjectScores[index] ?? 0;

                                int subTotal =
                                    subjectTotals[index] ?? 0;

                                double percent =
                                    subTotal == 0
                                        ? 0
                                        : (subScore / subTotal) * 100;

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),

                                  child: Text(
                                    "${subjects[index]}: "
                                    "$subScore/$subTotal "
                                    "(${percent.toStringAsFixed(1)}%)",

                                    style: TextStyle(
                                      fontSize: 14,
                                      color: percent >= 50
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// MOCK MODE REVIEW
                    if (examMode == "Mock" || examMode == "Study")
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),

                      child: Column(
                        children: subjectQuestions.entries
                            .expand((entry) {

                          int subjectIndex = entry.key;
                          List questions = entry.value;

                          return List.generate(
                            questions.length,
                            (i) {

                              var q = questions[i];

                              int correctIndex =
                                  q["answerIndex"];

                              int? userIndex =
                                  subjectAnswers[subjectIndex]?[i];

                              bool isCorrect =
                                  userIndex == correctIndex;

                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 6,
                                ),

                                child: Padding(
                                  padding: EdgeInsets.all(10),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [

                                      /// QUESTION
                                      Text(
                                        "Q${i + 1}",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      buildContent(
                                        q["question"],
                                      ),

                                      SizedBox(height: 10),

                                      /// USER ANSWER
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [

                                          Text(
                                            "Your Answer: ",
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          Expanded(
                                            child: userIndex == null
                                                ? Text(
                                                    "Not Answered",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.orange,
                                                    ),
                                                  )
                                                : optionsDisplay(
                                                    q["options"]
                                                        [userIndex],
                                                  ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 5),

                                      /// CORRECT ANSWER
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [

                                          Text(
                                            "Correct Answer: ",
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),

                                          Expanded(
                                            child: optionsDisplay(
                                              q["options"]
                                                  [correctIndex],
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 8),

                                      /// RESULT STATUS
                                      Text(
                                        userIndex == null
                                            ? "Not Attempted"
                                            : isCorrect
                                                ? "Correct"
                                                : "Wrong",

                                        style: TextStyle(
                                          color: userIndex == null
                                              ? Colors.orange
                                              : isCorrect
                                                  ? Colors.green
                                                  : Colors.red,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      /// EXPLANATION
                                      if ((q["explanation"] ?? "")
                                          .toString()
                                          .isNotEmpty) ...[

                                        Text(
                                          "Explanation:",
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color:
                                                Colors.blueGrey,
                                          ),
                                        ),

                                        SizedBox(height: 5),

                                        buildContent(
                                          q["explanation"],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FLOATING BUTTONS
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,

            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),

                  borderRadius:
                      BorderRadius.circular(15),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                    ),
                  ],
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    ElevatedButton(
                      onPressed: () {

                        Navigator.pushAndRemoveUntil(
                          context,

                          MaterialPageRoute(
                            builder: (_) => HomePage(),
                          ),

                          (route) => false,
                        );
                      },

                      child: Text("HomePage"),
                    ),

                    SizedBox(width: 15),
                  if (examMode == "Mock" || examMode == "Study")
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),

                      onPressed: () =>
                          retryWrongQuestions(context),

                      child: Text(
                        "Retry Wrong Questions",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    : Container(),
  );
}
}

class ResultHistoryPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result History"),

        actions: [
          IconButton(
            icon: Icon(Icons.delete),

            onPressed: () async {

              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Clear History"),
                    content: Text(
                      "Are you sure you want to delete all saved results?",
                    ),

                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text("Cancel"),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              /// DELETE ALL RESULTS
              if (confirm == true) {

                await isar.writeTxn(() async {
                  await isar.resultModels.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Result history cleared"),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: StreamBuilder<List<ResultModel>>(
        stream: isar.resultModels
            .where()
            .sortByDateDesc()
            .watch(fireImmediately: true),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data!;

          if (results.isEmpty) {
            return Center(child: Text("No results yet"));
          }

          return ListView.builder(
            itemCount: results.length,

            itemBuilder: (context, index) {
              final r = results[index];

              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                child: ListTile(
                  title: Text(
                    "${r.score}/${r.total} (${r.percentage.toStringAsFixed(1)}%)",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Mode: ${r.mode}"),
                      Text(
                        "Subjects: ${r.subjects.join(", ")}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Date: ${r.date.day}/${r.date.month}/${r.date.year} "
                        "${r.date.hour.toString().padLeft(2, '0')}:"
                        "${r.date.minute.toString().padLeft(2, '0')}",
                      ),

                      Text("Time Spent: ${r.timeSpent}s"),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }
}