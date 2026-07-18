import '../config/constants.dart';
import '../models/question.dart';
import '../models/score.dart';
import '../models/student.dart';
import 'api_client.dart';

class QuizService {
  final ApiClient _client = ApiClient();

  Future<List<Question>> getQuestions() async {
    final body = await _client.get(ApiConfig.questions);
    final list = (body['data'] as List<dynamic>? ?? []);
    return list.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<QuizResult> submitQuiz(Map<int, String> answers) async {
    final payload = answers.entries
        .map((e) => {"question_id": e.key, "answer": e.value})
        .toList();
    final body = await _client.post(ApiConfig.quizSubmit, payload);
    return QuizResult.fromJson(body);
  }

  /// Global leaderboard, sorted by the backend highest-score-first.
  /// Note: only contains student_id, not the student's name — pair with
  /// getAllStudents() below if you want to display names.
  Future<List<ScoreEntry>> getLeaderboard() async {
    final body = await _client.get(ApiConfig.quizScores);
    final list = (body['data'] as List<dynamic>? ?? []);
    return list.map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScoreEntry>> getMyScores() async {
    final body = await _client.get(ApiConfig.myScores);
    final list = (body['data'] as List<dynamic>? ?? []);
    return list.map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Student>> getAllStudents() async {
    final body = await _client.get(ApiConfig.students);
    final list = (body['data'] as List<dynamic>? ?? []);
    return list.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Admin-only actions below. The backend rejects these with a 403
  // ("Admins only") if the logged-in user's token doesn't carry the
  // is_admin claim, regardless of what the Flutter UI shows. ---

  Future<void> deleteStudent(int id) async {
    await _client.delete(ApiConfig.studentById(id));
  }

  Future<void> addQuestion(Question question) async {
    await _client.post(ApiConfig.questions, question.toCreateJson());
  }

  Future<void> importQuestionsFromExcel(String fileName, List<int> bytes) async {
    await _client.postMultipartFile(ApiConfig.questionsImport, 'file', fileName, bytes);
  }

  Future<void> deleteQuestion(int id) async {
    await _client.delete(ApiConfig.questionById(id));
  }
}
