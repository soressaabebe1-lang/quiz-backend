import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _quizService = QuizService();

  List<Question> _questions = [];
  final Map<int, String> _selectedAnswers = {};

  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final questions = await _quizService.getQuestions();
      setState(() => _questions = questions);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Could not load questions.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitQuiz() async {
    setState(() => _submitting = true);
    try {
      final result = await _quizService.submitQuiz(_selectedAnswers);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("No questions available yet.")),
      );
    }

    final allAnswered = _selectedAnswers.length == _questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final q = _questions[index];
          final options = {"A": q.optionA, "B": q.optionB, "C": q.optionC, "D": q.optionD};

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ${q.question}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // NOTE: we deliberately never read q.answer here — the
                  // backend sends it along with every question, but showing
                  // it would let students see the correct answer directly.
                  ...options.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text("${entry.key}. ${entry.value}"),
                      value: entry.key,
                      groupValue: _selectedAnswers[q.id],
                      onChanged: (value) {
                        setState(() => _selectedAnswers[q.id] = value!);
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: (allAnswered && !_submitting) ? _submitQuiz : null,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(allAnswered
                  ? "Submit Quiz"
                  : "Answer all questions (${_selectedAnswers.length}/${_questions.length})"),
        ),
      ),
    );
  }
}
