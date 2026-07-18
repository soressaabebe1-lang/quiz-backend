/// Central place for backend config.
///
/// NOTE FOR EMULATORS/DEVICES:
/// - Android emulator: use http://10.0.2.2:5000 instead of localhost
/// - iOS simulator: http://127.0.0.1:5000 works fine
/// - Physical device: use your computer's LAN IP, e.g. http://192.168.1.5:5000
class ApiConfig {
  static const String baseUrl = "https://quiz-backend-fsx2.onrender.com";

  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";

  static const String students = "$baseUrl/students";
  static String studentById(int id) => "$baseUrl/students/$id";

  static const String questions = "$baseUrl/question";
  static String questionById(int id) => "$baseUrl/question/$id";

  static const String quizSubmit = "$baseUrl/quiz/submit";
  static const String quizScores = "$baseUrl/quiz/scores";
  static const String myScores = "$baseUrl/quiz/my-scores";
}
