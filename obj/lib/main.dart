/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;*/
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

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
  @override
  _MySecondPageState createState() => _MySecondPageState();
}
class _MySecondPageState extends State<SecondPage>{
  Map<String, bool> hobbies = {
    "ENS211": false,
    "PRE11": false,
    "CPE481": false,
    "CPE461": false,
  };
  List<String> selectedSubjects = [];
  void updateSelectedSubjects() {
  selectedSubjects = hobbies.entries
      .where((entry) => entry.value)   // keep only true
      .map((entry) => entry.key)      // get the subject name
      .toList();
}
  @override
  Widget build(BuildContext context){
    return Scaffold(
    /*need to add more things to the appbar */
    appBar: AppBar(
      title: Text("Pick Your Subjects",
        style:TextStyle(
          fontSize: 15.0,
        ),  
        ),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
    ),
     body: ListView(
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
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context)=> ThirdPage()));
        updateSelectedSubjects();
        //print(selectedSubjects);  
      },
      backgroundColor: Colors.blueGrey,
      child: Text("Next")
    )
    );
  }
}
class ThirdPage extends StatefulWidget{
  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}
class _MyThirdPageState extends State<ThirdPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
    /*need to add more things to the appbar */
    appBar: AppBar(
      title: Text("",
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
      onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> FourthPage()),); },
      backgroundColor: Colors.blueGrey,
      child: Text("Next")
    )
  );
}
}
class FourthPage extends StatefulWidget{
  @override
  _MyFourthPageState createState() => _MyFourthPageState();
}
class _MyFourthPageState extends State<FourthPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final rawData =
        await rootBundle.loadString("assets/questions.csv");

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

    setState(() {
      questions = loadedQuestions;
    });
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

  @override
  Widget build(BuildContext context) {

    // If questions are empty, show message instead of loader
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("CBT App")),
        body: Center(
          child: Text(
            "No questions found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    var currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("CBT App")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Question ${currentQuestionIndex + 1}/${questions.length}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              currentQuestion["question"],
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),

            ...(currentQuestion["options"] as List)
                .map((option) => ListTile(
                      title: Text(option.toString()),
                    ))
                .toList(),

            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousQuestion,
                  child: Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text("Next"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
