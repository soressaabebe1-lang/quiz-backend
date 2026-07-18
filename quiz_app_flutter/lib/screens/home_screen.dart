import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'my_scores_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<bool>(
          future: AuthService().isAdmin(),
          builder: (context, snapshot) {
            final isAdmin = snapshot.data ?? false;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MenuCard(
                  icon: Icons.quiz,
                  label: "Take Quiz",
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.leaderboard,
                  label: "Leaderboard",
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.history,
                  label: "My Scores",
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyScoresScreen()),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.admin_panel_settings,
                    label: "Admin Panel",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(label, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
