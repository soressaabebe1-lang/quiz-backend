import 'package:flutter/material.dart';
import '../models/score.dart';
import '../models/student.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _quizService = QuizService();

  List<ScoreEntry> _scores = [];
  Map<int, String> _studentNames = {};
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // GET /quiz/scores only returns student_id, not names, so we fetch
      // the student list separately and join them client-side.
      final results = await Future.wait([
        _quizService.getLeaderboard(),
        _quizService.getAllStudents(),
      ]);
      final scores = results[0] as List<ScoreEntry>;
      final students = results[1] as List<Student>;

      setState(() {
        _scores = scores;
        _studentNames = {for (final s in students) s.id: s.name};
      });
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Could not load leaderboard.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _scores.isEmpty
                    ? const Center(child: Text("No scores yet."))
                    : ListView.builder(
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          final entry = _scores[index];
                          final name = _studentNames[entry.studentId] ?? "Student #${entry.studentId}";
                          return ListTile(
                            leading: CircleAvatar(child: Text("${index + 1}")),
                            title: Text(name),
                            subtitle: Text(entry.date),
                            trailing: Text(
                              "${entry.score}/${entry.total}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
