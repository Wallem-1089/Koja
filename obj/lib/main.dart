//import 'package:flutter/material.dart';//
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
    if (selectedDuration == "15 Minutes") return 900;
    if (selectedDuration == "45 Minutes") return 2700;
    if (selectedDuration == "2 Hours") return 7200;
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

                ///  NEW: EXAM MODE DROPDOWN
                Text(
                  "Select Exam Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                 SizedBox(height: 20),

              DropdownButton<String>(
                value: selectedExamMode,
                isExpanded: true,
                items: ["Mock", "Exam", "Study"] //new
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
      return "assets/$subject.json";
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
            "options": List<String>.from(q["options"]),
            "answerIndex": q["answerIndex"],
            "explanation": q["explanation"] ?? "", //  NEW
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
     ///  Prevent double submission
    if (isSubmitting) return;

    isSubmitting = true;

    countdownTimer?.cancel();

    int score = 0;
    int total = 0;
    int timeSpentSeconds = widget.examDuration - remainingSeconds; // new

    /// NEW: per subject tracking
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
    /// (capture current time)
    DateTime submissionTime = DateTime.now();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(
              score: score,
              total: total,
              examMode: widget.examMode,
              subjectQuestions: subjectQuestions,
              subjectAnswers: subjectAnswers, //new
              submissionTime: submissionTime, // new
              timeSpentSeconds: timeSpentSeconds,
              totalDuration: widget.examDuration, // new
              /// ✅ NEW
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
    List<String> options = List<String>.from(currentQuestion["options"]);

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

                  SizedBox(height: 8),

                  ...List.generate(options.length, (index) {
                    String optionLetter = ["A", "B", "C", "D"][index];
                    return RadioListTile<int>(
                      title: Row(
                        children: [
                          Text("$optionLetter. "),
                          Expanded(child: buildContent(options[index])),
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
                            : buildContent(currentQuestion["options"][userIndex]),

                        SizedBox(height: 5),

                        /// CORRECT ANSWER
                        Text(
                          "Correct Answer:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        buildContent(currentQuestion["options"][correctIndex]),

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
        examMode: "Retry", // 🔥 NEW MODE
        examDuration: retryDuration, // or shorter if you want
        preloadedQuestions: retryQuestions, // 🔥 IMPORTANT
      ),
    ),
  );
}


  @override
Widget build(BuildContext context) {
  double percentage = (score / total) * 100;
  double avgTimePerQuestion = timeSpentSeconds / total; //new
  double efficiency = (timeSpentSeconds / totalDuration) * 100;

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

                SizedBox(height: 7), //20

                Text(
                  "$score / $total",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 7), //20

                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 28,
                    color: percentage >= 50 ? Colors.green : Colors.red,
                  ),
                ),

                SizedBox(height: 5),

                Wrap(
                  spacing: 16, // horizontal space between items
                  runSpacing: 8, // vertical space if it wraps
                  children: [
                    Text(
                      "Submitted: ${formatSubmissionTime(submissionTime)}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                    Text(
                      "Time: ${formatTimeSpent(timeSpentSeconds)}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                    Text(
                      "Avg/Q: ${formatSeconds(avgTimePerQuestion)}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                    Text(
                      "Efficiency: ${efficiency.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 14,
                        color: efficiency < 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        /// PERFORMANCE PER SUBJECT (TEXT STYLE)
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 2),

                Wrap(
                  spacing: 12,   // space between items horizontally
                  runSpacing: 8, // space between rows if they wrap down

                  children: List.generate(subjects.length, (index) {

                    int subScore = subjectScores[index] ?? 0;
                    int subTotal = subjectTotals[index] ?? 0;

                    double percent =
                        subTotal == 0 ? 0 : (subScore / subTotal) * 100;

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${subjects[index]}: $subScore/$subTotal (${percent.toStringAsFixed(1)}%)",
                        style: TextStyle(
                          fontSize: 14,
                          color: percent >= 50 ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ), ), ),


        ///  MOCK MODE REVIEW
        if (examMode == "Mock")
          Expanded(
            flex: 4,
            child: ListView(
              padding: EdgeInsets.all(10),
              children: subjectQuestions.entries.expand((entry) {

                int subjectIndex = entry.key;
                List questions = entry.value;

                return List.generate(questions.length, (i) {

                  var q = questions[i];

                  int correctIndex = q["answerIndex"];
                  int? userIndex = subjectAnswers[subjectIndex]?[i];

                  bool isCorrect = userIndex == correctIndex;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// QUESTION
                          Text(
                            "Q${i + 1}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          buildContent(q["question"]),

                          SizedBox(height: 10),

                          /// USER ANSWER
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Answer: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: userIndex == null
                                    ? Text(
                                        "Not Answered",
                                        style: TextStyle(color: Colors.orange),
                                      )
                                    : buildContent(q["options"][userIndex]),
                              ),
                            ],
                          ),

                          SizedBox(height: 5),

                          /// CORRECT ANSWER
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
                                  q["options"][correctIndex],
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),

                          /// ✅ EXPLANATION
                          if ((q["explanation"] ?? "").toString().isNotEmpty) ...[

                            Text(
                              "Explanation:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),

                            SizedBox(height: 5),

                            buildContent(q["explanation"]),
                          ],

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 🔥 centers both buttons
            children: [

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
                  );
                },
                child: Text("Back to Home Page"),
              ),

              SizedBox(width: 15),

              /// 🔥 NEW RETRY BUTTON
              if (examMode == "Mock" || examMode == "Study")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () => retryWrongQuestions(context),
                  child: Text("Retry Wrong Questions"),
                ),
            ],
          ),
        ),

      ],
    ), 
  );
}
}
class RetryPage extends StatelessWidget {
  final List<Map<String, dynamic>> wrongQuestions;

  RetryPage({required this.wrongQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Retry Wrong Questions")),

      body: ListView.builder(
        itemCount: wrongQuestions.length,
        itemBuilder: (context, index) {
          var q = wrongQuestions[index]["data"];

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Question ${index + 1}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(q["question"]),

                  SizedBox(height: 10),

                  ...List.generate(q["options"].length, (i) {
                    return Text("${["A","B","C","D"][i]}. ${q["options"][i]}");
                  }),

                  SizedBox(height: 10),

                  Text(
                    "Correct Answer: ${q["options"][q["answerIndex"]]}",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
