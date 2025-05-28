import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT Chat'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<ChatProvider>().createNewRoom();
            },
          ),
        ],
      ),
      drawer: const _ChatDrawer(),
      body: Column(
        children: [
          _buildBotSelector(context),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.currentRoom?.messages ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          const _MessageInput(),
        ],
      ),
    );
  }

  Widget _buildBotSelector(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showBotSelectionDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chatProvider.currentBot.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBotSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Bot'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ChatBot.bots.length,
                itemBuilder: (context, index) {
                  final bot = ChatBot.bots[index];
                  return ListTile(
                    title: Text(bot.name),
                    subtitle: Text(bot.description),
                    onTap: () {
                      context.read<ChatProvider>().setCurrentBot(bot);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.content,
          style: TextStyle(color: message.isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class _ChatDrawer extends StatelessWidget {
  const _ChatDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final rooms =
              chatProvider.chatRooms
                  .where((room) => room.bot.id == chatProvider.currentBot.id)
                  .toList();

          return Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Center(
                  child: Text(
                    '${chatProvider.currentBot.name}\'s Chats',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final isSelected = room.id == chatProvider.currentRoom?.id;

                    return ListTile(
                      title: Text(room.title),
                      subtitle: Text(
                        room.messages.isEmpty
                            ? 'No messages'
                            : room.messages.last.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isSelected,
                      onTap: () {
                        chatProvider.selectRoom(room.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput();

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return IconButton(
                onPressed: chatProvider.isLoading ? null : _sendMessage,
                icon:
                    chatProvider.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send),
                color: Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }
}
