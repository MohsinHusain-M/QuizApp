import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final List <Map<String, dynamic>> mcqs;

  const ResultScreen({super.key,
    required this.score,
    required this.total,
    required this.mcqs
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (score/ total) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results'),automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Score: $score / $total',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Percentage: ${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text(
                "Correct Answers:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: mcqs.length,
                  itemBuilder: (context, index) {
                    final question = mcqs[index];
                    final String correctAnswerKey = question['correct_answer'];
                    final String userAnswerKey = question['user_answer'] ?? "";
                    final String correctAnswerText = question['options'][correctAnswerKey];
                    final String userAnswerText = question['options'][userAnswerKey] ?? 'No Answer';

                    //check if user answered correctly
                    final bool isCorrect = userAnswerKey == correctAnswerKey;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isCorrect ? Colors.green : Colors.red, //Green for correct,rred for incorrect
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text('Q${index + 1}: ${question['question']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(!isCorrect) Text('Your Answer: $userAnswerText'),
                            Text('Correct Answer: $correctAnswerText')
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  }, //Retry button goes back
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Retry Quiz"),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
      ),
    );
  }
}
