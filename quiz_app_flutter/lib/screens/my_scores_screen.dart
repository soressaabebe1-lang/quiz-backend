import 'package:flutter/material.dart';
import '../models/score.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';

class MyScoresScreen extends StatefulWidget {
  const MyScoresScreen({super.key});

  @override
  State<MyScoresScreen> createState() => _MyScoresScreenState();
}

class _MyScoresScreenState extends State<MyScoresScreen> {
  final _quizService = QuizService();

  List<ScoreEntry> _scores = [];
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
      final scores = await _quizService.getMyScores();
      setState(() => _scores = scores);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Could not load your scores.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Scores")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _scores.isEmpty
                    ? const Center(child: Text("You haven't taken a quiz yet."))
                    : ListView.builder(
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          final entry = _scores[index];
                          return ListTile(
                            leading: const Icon(Icons.assignment_turned_in),
                            title: Text("${entry.score}/${entry.total} (${entry.percentage.toStringAsFixed(1)}%)"),
                            subtitle: Text(entry.date),
                          );
                        },
                      ),
      ),
    );
  }
}
