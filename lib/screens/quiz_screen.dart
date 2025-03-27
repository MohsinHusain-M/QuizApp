import 'dart:async';

import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mcqs;
  final String difficulty;

  const QuizScreen({super.key, required this.mcqs, required this.difficulty});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;

  //timer bonus
  Timer? _timer;
  int _timeLeft = 25;

  //start the timer on init
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  //start timer function
  void _startTimer() {
    _timeLeft = 20;
    _timer?.cancel(); // cancel existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _nextQuestion(); //move the next question when timer finished
      }
    });
  }

  //check answer submiited
  void _checkAnswer(String selectedKey) {
    if (_answered) return; //prevent multiple selections

    _timer?.cancel(); //stop timer on selection
    final correctAnswer = widget.mcqs[_currentQuestionIndex]['correct_answer'];
    bool isCorrect = selectedKey == correctAnswer;

    setState(() {
      _selectedOption = selectedKey;
      _answered = true;
      _isCorrect = isCorrect;

      if (isCorrect) {
        _score++;
      }
      // Store user's answer in mcqs list
      widget.mcqs[_currentQuestionIndex]['user_answer'] = selectedKey;
    });

    //move to the next question after a short delay
    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  //get next question
  void _nextQuestion() {
    if (_currentQuestionIndex < widget.mcqs.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _answered = false;
      });
      _startTimer(); //restart timer for next question
    } else {
      _showCompletionDialog();
    }
  }

  Future<void> _saveScore() async {
    //Save score to local storage
    final prefs = await SharedPreferences.getInstance();
    List<String> pastScores = prefs.getStringList('past_scores') ?? [];
    pastScores.add('Score: $_score (${widget.difficulty})');
    await prefs.setStringList('past_scores', pastScores);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, //prevent dismiss
      builder:
          (context) => AlertDialog(
            title: const Text("Quiz Completed!"),
            content: const Text("Congrats! You have finished all questions."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _showResultScreen(); // Go back to result screen
                  _saveScore(); // save the score
                },
                child: const Text("Show result!"),
              ),
            ],
          ),
    );
  }

  //show result screen
  void _showResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultScreen(
              score: _score,
              total: widget.mcqs.length,
              mcqs: widget.mcqs,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.mcqs[_currentQuestionIndex];
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Timer Display
                Center(
                  child: Text(
                    'Time Left: $_timeLeft s',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 5 ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Q${_currentQuestionIndex + 1}: ${question['question']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...question['options'].entries.map((entry) {
                  String optionKey = entry.key;
                  bool isSelected = _selectedOption == optionKey;
                  bool isCorrectOption = question['correct_answer'] == optionKey;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _checkAnswer(optionKey),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor:
                            _answered
                                ? (isSelected
                                    ? (isCorrectOption ? Colors.green : Colors.red)
                                    : Colors.grey[300])
                                : Colors.white,
                      ),
                      child: Text('${entry.key}: ${entry.value}'),
                    ),
                  );
                }).toList(),
                if (_answered)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _isCorrect
                          ? 'Correct!'
                          : 'Incorrect The correct answer is: ${question['correct_answer']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ) ,
    );
  }
}
