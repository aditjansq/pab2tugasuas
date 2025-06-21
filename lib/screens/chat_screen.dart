import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat - Preloved')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(child: Center(child: Text('No messages yet.'))),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Type a message...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
