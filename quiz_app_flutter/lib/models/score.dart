class ScoreEntry {
  final int id;
  final int studentId;
  final int score;
  final int total;
  final String date;

  ScoreEntry({
    required this.id,
    required this.studentId,
    required this.score,
    required this.total,
    required this.date,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      score: json['score'] as int,
      total: json['total'] as int,
      date: json['date'] as String,
    );
  }

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}

class QuizResult {
  final String status;
  final int score;
  final int total;
  final double percentage;
  final String result;

  QuizResult({
    required this.status,
    required this.score,
    required this.total,
    required this.percentage,
    required this.result,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      status: json['status'] as String,
      score: json['score'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      result: json['result'] as String,
    );
  }

  bool get passed => result.toLowerCase() == "passed";
}
