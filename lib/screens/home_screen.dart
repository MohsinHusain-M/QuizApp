import 'package:flutter/material.dart';
import '../services/quiz_groq_api.dart';
import 'quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  bool _isLoading = false;
  final QuizGroqService _quizService = QuizGroqService();
  String _selectedDifficulty = "Easy"; //default easy
  List<String> _pastScores = [];

  @override
  void initState() {
    super.initState();
    _loadPastScores();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPastScores();
    });
  }

  Future<void> _loadPastScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pastScores = prefs.getStringList('past_scores') ?? [];
    });
  }

  Future<void> _fetchAndNavigate() async{
    setState(() {
      _isLoading = true;
    });

    try {
      final mcqs = await _quizService.generateMCQs(_selectedDifficulty);
      if (mcqs != null && mcqs.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(mcqs: mcqs, difficulty: _selectedDifficulty,)),
        );
      } else {
        _showError('No questions received. Try again.');
      }
    } catch (e) {
      _showError('Failed to fetch quiz: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Quiz GK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Difficulty:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: ["Easy", "Medium", "Hard"].map((difficulty) {
                return RadioListTile(
                  title: Text(difficulty),
                  value: difficulty,
                  groupValue: _selectedDifficulty,
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _fetchAndNavigate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Quiz'),
            ),
            const SizedBox(height: 20,),
            const Text(
              'Past Scores:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10,),
            Flexible(
                child: _pastScores.isEmpty
                    ? const Text('No past scores available', style: TextStyle(fontSize: 16))
                    : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _pastScores.length,
                        itemBuilder: (context, index){
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center, //center content horizontaly
                              children: [
                                const Icon(Icons.star, color: Colors.amber), //star icon
                                const SizedBox(width: 8), //spacing between icon and text
                                Text(
                                  _pastScores[index],
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            visualDensity: VisualDensity.compact,
                        );
                        },
                      ),
                )
            )
          ],
        ),
      ),
    );
  }
}




