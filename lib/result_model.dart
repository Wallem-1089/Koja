import 'package:isar/isar.dart';

part 'result_model.g.dart';

@collection
class ResultModel {
  Id id = Isar.autoIncrement;

  late int score;
  late int total;

  late List<String> subjects;

  late String mode; // Mock, Exam, Study

  late int duration; // total duration
  late int timeSpent;

  late DateTime date;

  late double percentage;

  /*late Map<String, int> subjectScores;*/
  late List<SubjectPerformance> performances;
  /*late Map<String, int> subjectTotals;*/
}
@embedded
class SubjectPerformance {
  late String subject;
  late int score;
  late int total;
}