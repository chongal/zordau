import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ZordauAIScreen extends StatefulWidget {
  const ZordauAIScreen({super.key});

  @override
  State<ZordauAIScreen> createState() => _ZordauAIScreenState();
}

class _ZordauAIScreenState extends State<ZordauAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user'/'ai', 'text': '...'}
  bool _isLoading = false;

  final String webhookUrl = 'https://aminabaimakhanova.app.n8n.cloud/webhook/zordau_ai'; // Production webhook URL

  Future<void> sendMessage(String question) async {
    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"question": question}),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final String answer = data['answer'] ?? data['message'] ?? 'Извините, не удалось получить ответ.';

      setState(() {
        _messages.add({'role': 'ai', 'text': answer});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Ошибка при получении ответа: $e'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZORDAU Bot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите вопрос...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () {
                    final question = _controller.text.trim();
                    if (question.isNotEmpty) {
                      _controller.clear();
                      sendMessage(question);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}