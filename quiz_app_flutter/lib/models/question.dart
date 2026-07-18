/// Mirrors the backend's response shape from GET /question, which uses
/// capitalized keys ("Question", "Answer") — different from the lowercase
/// keys ("question", "answer") expected when POSTing a new question.
///
/// IMPORTANT: `answer` is included here because the backend currently sends
/// it back with every question. Do NOT show `answer` anywhere in the
/// quiz-taking UI — only use it if you're building an admin/review screen.
class Question {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String answer;

  Question({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['Question'] as String,
      optionA: json['A'] as String,
      optionB: json['B'] as String,
      optionC: json['C'] as String,
      optionD: json['D'] as String,
      answer: json['Answer'] as String,
    );
  }

  /// Body shape expected by POST /question (lowercase keys, single object —
  /// the backend was recently changed from accepting a list to accepting
  /// one question object per request).
  Map<String, dynamic> toCreateJson() {
    return {
      "question": question,
      "A": optionA,
      "B": optionB,
      "C": optionC,
      "D": optionD,
      "answer": answer,
    };
  }
}
