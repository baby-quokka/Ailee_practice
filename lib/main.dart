import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/chat_service.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => ChatProvider(
            chatService: ChatService(
              apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
            ),
          ),
      child: MaterialApp(
        title: 'ChatGPT Chat',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const ChatScreen(),
      ),
    );
  }
}
