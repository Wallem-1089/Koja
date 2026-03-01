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
      child: Image.asset('assets/new.png'),
    ),
   
    floatingActionButton: FloatingActionButton(
      onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> SecondPage()),); },
      backgroundColor: Colors.blueGrey,
      child: Text("Next")
    )
  );
}
}
class SecondPage extends StatefulWidget{
//  const SecondPage({super.key});

  @override
  _MySecondPageState createState() => _MySecondPageState();
}

class _MySecondPageState extends State<SecondPage> {

  Map<String, bool> hobbies = {
    "ENS211": false,
    "PRE11": false,
    "CPE481": false,
    "CPE461": false,
  };

  List<String> selectedSubjects = [];
  String selectedDuration = "30 Minutes";

  void updateSelectedSubjects() {
    selectedSubjects = hobbies.entries
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
                children: hobbies.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: hobbies[key],
                    onChanged: (bool? value) {
                      setState(() {
                        hobbies[key] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          VerticalDivider(),

          /// RIGHT SIDE — DROPDOWN ONLY
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

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThirdPage(
                examDuration: getDurationInSeconds(),
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

  ThirdPage({required this.examDuration});

  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}

class _MyThirdPageState extends State<ThirdPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  Map<int, int> selectedAnswers = {};

  late int remainingSeconds;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.examDuration;
    loadQuestions();
    startTimer(); // Auto start timer
  }

  Future<void> loadQuestions() async {
    final rawData = await rootBundle.loadString("assets/questions.csv");
    List<List<dynamic>> csvData = CsvToListConverter().convert(rawData);

    List<Map<String, dynamic>> loadedQuestions = [];
    for (var row in csvData) {
      loadedQuestions.add({
        "questionNumber": row[0],
        "question": row[1],
        "options": [row[2], row[3], row[4], row[5]],
        "answerIndex": row[6],
      });
    }

    setState(() {
      questions = loadedQuestions;
    });
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        submitQuiz(); // auto submit when time ends
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  void nextQuestion() {
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

  void submitQuiz() {
    countdownTimer?.cancel();

    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]["answerIndex"]) score++;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: score,
          total: questions.length,
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
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("CBT App")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          /// QUESTION AREA
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentQuestionIndex + 1}/${questions.length}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(currentQuestion["question"], style: TextStyle(fontSize: 22)),
                  SizedBox(height: 15),
                  ...List.generate(options.length, (index) {
                    return RadioListTile<int>(
                      title: Text(options[index].toString()),
                      value: index,
                      groupValue: selectedAnswers[currentQuestionIndex],
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[currentQuestionIndex] = value!;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          /// BUTTON SECTION (Previous, Next, Submit)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentQuestionIndex == 0 ? null : previousQuestion,
                    child: Text("Previous"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentQuestionIndex == questions.length - 1 ? null : nextQuestion,
                    child: Text("Next"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black12),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 20, // adjust based on your needs
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                bool isAnswered = selectedAnswers.containsKey(index);
                bool isCurrent = index == currentQuestionIndex;

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
                        color: isCurrent || isAnswered ? Colors.white : Colors.black,
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
