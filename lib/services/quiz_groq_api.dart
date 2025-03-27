import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class QuizGroqService{
  static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String apiKey = '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';


  Future<List<Map<String, dynamic>>?> generateMCQs(String difficulty) async{
    try{
    String prompt = '''Generate 5 random multiple-choice questions on general knowledge 
    with a $difficulty difficulty level.
    Each should have a question, 4 options (A, B, C, D), and the correct answer clearly marked.
    Return only valid JSON in this format:
    [
      {
        'question': 'What is 2+2?',
        'options': { 'A': '3', 'B': '4', 'C': '5', 'D': '6' },
        'correct_answer': 'B'
      }
    ]
    ''';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type' : 'application/json',
          'Authorization' : 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model' : 'llama3-8b-8192',
          'messages':[
            {
              'role': 'system',
              'content': 'Your are a quiz generator bot that only returns valid JSON'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7
        }),
      );

      //response
      if (response.statusCode == 200){
        final data = jsonDecode(response.body);
        log('Success: ${jsonEncode(data)}');
        final mcqList = jsonDecode(data['choices'][0]['message']['content']);
        return List<Map<String, dynamic>>.from(mcqList);
      } else{
        log('Error: ${response.body}');
        return null;
      }
    } catch(e){
      log('Error: $e');
      return null;
    }
  }
}