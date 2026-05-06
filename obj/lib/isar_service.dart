import 'main.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'result_model.dart';

Future<void> saveResultToIsar({
  required int score,
  required int total,
  required List<String> subjects,
  required String mode,
  required int duration,
  required int timeSpent,
  required DateTime date,
  required List<SubjectPerformance> performances,
}) async {

  final isar = Isar.getInstance(); // or your instance getter

  final result = ResultModel()
    ..score = score
    ..total = total
    ..subjects = subjects
    ..mode = mode
    ..duration = duration
    ..timeSpent = timeSpent
    ..date = date
    ..percentage = (score / total) * 100
    ..performances = performances;

  await isar!.writeTxn(() async {
    await isar.resultModels.put(result);
  });
}