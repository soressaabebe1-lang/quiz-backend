import 'package:flutter/material.dart';
import '../models/score.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.passed ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text("Result"), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              result.passed ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 96,
            ),
            const SizedBox(height: 16),
            Text(
              result.result,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              "${result.score} / ${result.total} (${result.percentage}%)",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
