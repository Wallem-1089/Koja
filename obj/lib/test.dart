import 'dart:io';

void main() async {
  // Load CSV file from the project folder
  File file = File('obj/assets/questions.csv');

  // Check if file exists
  if (!await file.exists()) {
    print("Error: questions.csv file not found!");
    return;
  }

  // Read lines from CSV
  List<String> lines = await file.readAsLines();
  print(lines);

  int score = 0;

  for (String line in lines) {
    if (line.trim().isEmpty) continue;

    // Split line by comma
    List<String> values = line.split(',');

    String question = values[0];
    List<String> options = values.sublist(1, 5);
    int answerIndex = int.parse(values[5]);

    print("\n$question");
    print("Options: $options");

    stdout.write("Enter answer: ");
    String? choice = stdin.readLineSync();

    if (choice == options[answerIndex]) {
      print("Correct!");
      score++;
    } else {
      print("Incorrect!");
    }
  }

  print("\nFinal Score: $score");
}
