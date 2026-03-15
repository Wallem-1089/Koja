/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;*/
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:async';


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

  Map<String, bool> checkbox_pick = {
    "ENS211": false,
    "PRE211": false,
    "CPE481": false,
    "CPE461": false,
  };

  List<String> selectedSubjects = [];
  String selectedDuration = "30 Minutes";

  void updateSelectedSubjects() {

    selectedSubjects = checkbox_pick.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

  }

  int getDurationInSeconds() {

    if (selectedDuration == "30 Minutes") return 1800;
    if (selectedDuration == "45 Minutes") return 2700;
    return 3600;

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

          /// LEFT SIDE — SUBJECT CHECKBOXES
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),

              child: ListView(

                children: checkbox_pick.keys.map((String key) {

                  return CheckboxListTile(

                    title: Text(key),

                    value: checkbox_pick[key],

                    onChanged: (bool? value) {

                      setState(() {
                        checkbox_pick[key] = value!;
                      });

                    },

                  );

                }).toList(),
              ),
            ),
          ),

          VerticalDivider(),

          /// RIGHT SIDE — DROPDOWN
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
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          updateSelectedSubjects();

          if (selectedSubjects.isEmpty) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please select at least one subject"),
              ),
            );

            return;

          }

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context) => ThirdPage(

                examDuration: getDurationInSeconds(),

                selectedSubjects: selectedSubjects,

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

  ThirdPage({
    required this.examDuration,
    required this.selectedSubjects,
  });

  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}

class _MyThirdPageState extends State<ThirdPage> {

  late List<String> csvFiles;
  late List<String> subjects;

  Map<int, List<Map<String, dynamic>>> subjectQuestions = {};
  Map<int, Map<int, int>> subjectAnswers = {};

  int currentSubject = 0;
  int currentQuestionIndex = 0;

  late int remainingSeconds;
  Timer? countdownTimer;

  @override
  void initState() {

    super.initState();

    remainingSeconds = widget.examDuration;

    /// SUBJECTS FROM SCREEN 2
    subjects = widget.selectedSubjects;

    /// CONVERT TO CSV PATHS
    csvFiles = subjects.map((subject) {
      return "assets/$subject.csv";
    }).toList();

    loadQuestions();

    startTimer();

  }
  Future<void> loadQuestions() async {

  try {

    /// LOAD ALL CSV FILES IN PARALLEL
    List<String> rawFiles = await Future.wait(
      csvFiles.map((file) => rootBundle.loadString(file)),
    );

    for (int i = 0; i < rawFiles.length; i++) {

      List<List<dynamic>> csvData =
          CsvToListConverter().convert(rawFiles[i]);

      List<Map<String, dynamic>> loadedQuestions = [];

      for (var row in csvData) {

        /// Skip invalid rows
        if (row.length < 7) continue;

        loadedQuestions.add({
          "questionNumber": row[0],
          "question": row[1],
          "options": [
            row[2].toString(),
            row[3].toString(),
            row[4].toString(),
            row[5].toString(),
          ],
          "answerIndex": row[6],
        });

      }

      subjectQuestions[i] = loadedQuestions;
      subjectAnswers[i] = {};

    }

    if (mounted) {
      setState(() {});
    }

  } catch (e) {

    print("CSV LOAD ERROR: $e");

  }
}


  /*Future<void> loadQuestions() async {

    for (int i = 0; i < csvFiles.length; i++) {

      final rawData = await rootBundle.loadString(csvFiles[i]);

      List<List<dynamic>> csvData =
          CsvToListConverter().convert(rawData);

      List<Map<String, dynamic>> loadedQuestions = [];

      for (var row in csvData) {

        loadedQuestions.add({

          "questionNumber": row[0],

          "question": row[1],

          "options": [row[2], row[3], row[4], row[5]],

          "answerIndex": row[6],

        });

      }

      subjectQuestions[i] = loadedQuestions;
      subjectAnswers[i] = {};
    }

    setState(() {});
  } */

  //to test for file loading error
  /*Future<void> loadQuestions() async {

  try {

    for (int i = 0; i < csvFiles.length; i++) {

      final rawData = await rootBundle.loadString(csvFiles[i]);

      List<List<dynamic>> csvData =
          CsvToListConverter().convert(rawData);

      List<Map<String, dynamic>> loadedQuestions = [];

      for (var row in csvData) {

        if (row.length < 7) continue;

        loadedQuestions.add({
          "questionNumber": row[0],
          "question": row[1],
          "options": [row[2], row[3], row[4], row[5]],
          "answerIndex": row[6],
        });

      }

      subjectQuestions[i] = loadedQuestions;
      subjectAnswers[i] = {};

    }

    setState(() {});

  } catch (e) {

    print("CSV LOAD ERROR: $e");

  }

}*/

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

      if (mounted) {
        setState(() {});
      }

    },
  );
}

  // old timer, trying to prevent unnecessary crashes
  /*void startTimer() {

    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (timer) {

      if (remainingSeconds > 0) {

        setState(() {
          remainingSeconds--;
        });

      } else {

        timer.cancel();
        submitQuiz();

      }

    });

  }*/

  String formatTime(int seconds) {

    int minutes = seconds ~/ 60;
    int secs = seconds % 60;

    return "$minutes:${secs.toString().padLeft(2, '0')}";

  }

  void nextQuestion() {

    var questions = subjectQuestions[currentSubject]!;

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

  void submitQuiz() {

    countdownTimer?.cancel();

    int score = 0;
    int total = 0;

    subjectQuestions.forEach((subjectIndex, questions) {

      for (int i = 0; i < questions.length; i++) {

        total++;

        if (subjectAnswers[subjectIndex]![i] ==
            questions[i]["answerIndex"]) {

          score++;

        }

      }

    });

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (context) =>
            ResultPage(score: score, total: total),
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

    if (subjectQuestions.isEmpty && csvFiles.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("CBT App")),
        body: Center(child: CircularProgressIndicator()),
      );

    }

    var questions = subjectQuestions[currentSubject]!;
    var currentQuestion = questions[currentQuestionIndex];
    List options = currentQuestion["options"];

    return Scaffold(

      appBar: AppBar(
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

                  Text(
                    currentQuestion["question"],
                    style: TextStyle(fontSize: 22),
                  ),

                  SizedBox(height: 15),

                  ...List.generate(options.length, (index) {

                    return RadioListTile<int>(

                      title: Text(options[index].toString()),

                      value: index,

                      groupValue:
                          subjectAnswers[currentSubject]![currentQuestionIndex],

                      onChanged: (value) {

                        setState(() {

                          subjectAnswers[currentSubject]![currentQuestionIndex] =
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
                    onPressed: currentQuestionIndex ==
                            questions.length - 1
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

          /// NAVIGATION GRID
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

                      borderRadius:
                          BorderRadius.circular(4),
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
    );
  }
}
//modify this code to include the corrections to make the code run faster

class ResultPage extends StatelessWidget {
  final int score;
  final int total;

  ResultPage({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    double percentage = (score / total) * 100;

    return Scaffold(
      appBar: AppBar(title: Text("Exam Result")),
      body: Center(
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
                color: percentage >= 50
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                 Navigator.push(context,MaterialPageRoute(builder: (context)=> HomePage()));
              },
              child: Text("Back to Home Page"),
            ),
          ],
        ),
      ),
    );
  }
}
