import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider({required ChatService chatService}) : _chatService = chatService;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(content);
      final botMessage = ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
