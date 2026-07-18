import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/student.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';

/// Admin-only screen. The Home screen only shows the link to get here if
/// the logged-in user's stored is_admin flag is true, but the REAL
/// enforcement happens server-side: every action here calls an endpoint
/// protected by @admin_required, so a non-admin token gets a 403 even if
/// someone reached this screen some other way.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Students", icon: Icon(Icons.people)),
            Tab(text: "Questions", icon: Icon(Icons.quiz)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StudentsTab(),
          _QuestionsTab(),
        ],
      ),
    );
  }
}

// --- Students tab -----------------------------------------------------

class _StudentsTab extends StatefulWidget {
  const _StudentsTab();

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  final _quizService = QuizService();
  List<Student> _students = [];
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
      final students = await _quizService.getAllStudents();
      setState(() => _students = students);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndDelete(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete student?"),
        content: Text("This permanently deletes '${student.name}'. This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _quizService.deleteStudent(student.id);
      if (mounted) {
        setState(() => _students.removeWhere((s) => s.id == student.id));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(student.name),
            subtitle: Text("Age ${student.age} · ID ${student.id}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmAndDelete(student),
            ),
          );
        },
      ),
    );
  }
}

// --- Questions tab ------------------------------------------------------

class _QuestionsTab extends StatefulWidget {
  const _QuestionsTab();

  @override
  State<_QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<_QuestionsTab> {
  final _quizService = QuizService();
  List<Question> _questions = [];
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
      final questions = await _quizService.getQuestions();
      setState(() => _questions = questions);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteQuestion(Question question) async {
    try {
      await _quizService.deleteQuestion(question.id);
      if (mounted) {
        setState(() => _questions.removeWhere((q) => q.id == question.id));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openAddQuestionSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddQuestionForm(quizService: _quizService),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            return ListTile(
              title: Text(q.question),
              subtitle: Text("Correct answer: ${q.answer}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQuestion(q),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddQuestionSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddQuestionForm extends StatefulWidget {
  final QuizService quizService;
  const _AddQuestionForm({required this.quizService});

  @override
  State<_AddQuestionForm> createState() => _AddQuestionFormState();
}

class _AddQuestionFormState extends State<_AddQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _cController = TextEditingController();
  final _dController = TextEditingController();
  String _correctAnswer = "A";
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final question = Question(
        id: 0, // ignored by toCreateJson(); backend assigns the real id
        question: _questionController.text.trim(),
        optionA: _aController.text.trim(),
        optionB: _bController.text.trim(),
        optionC: _cController.text.trim(),
        optionD: _dController.text.trim(),
        answer: _correctAnswer,
      );
      await widget.quizService.addQuestion(question);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _dController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Question", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: "Question"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aController,
                decoration: const InputDecoration(labelText: "Option A"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              TextFormField(
                controller: _bController,
                decoration: const InputDecoration(labelText: "Option B"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              TextFormField(
                controller: _cController,
                decoration: const InputDecoration(labelText: "Option C"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              TextFormField(
                controller: _dController,
                decoration: const InputDecoration(labelText: "Option D"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _correctAnswer,
                decoration: const InputDecoration(labelText: "Correct answer"),
                items: const ["A", "B", "C", "D"]
                    .map((letter) => DropdownMenuItem(value: letter, child: Text(letter)))
                    .toList(),
                onChanged: (value) => setState(() => _correctAnswer = value!),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Add Question"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
