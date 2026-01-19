import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_container.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/chat_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/history_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _loadMessages() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final msgs = await _chatService.fetchMessages(uid);
    setState(() {
      _messages.clear();
      _messages.addAll(msgs.map((m) => {
            'isUser': m.isUser,
            'message': m.message,
            'time': _formatTime(m.createdAt),
          }));
    });
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final now = DateTime.now();
    final userMsg = ChatMessage(
      userId: uid,
      isUser: true,
      message: _controller.text,
      createdAt: now,
    );
    setState(() {
      _messages.add({
        'isUser': true,
        'message': userMsg.message,
        'time': _formatTime(now),
      });
      _controller.clear();
    });
    _chatService.saveMessage(userMsg);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final botNow = DateTime.now();
      final botMsg = ChatMessage(
        userId: uid,
        isUser: false,
        message: 'I found some great casual styles for you! How about a beige linen shirt with dark chinos?',
        createdAt: botNow,
      );
      setState(() {
        _messages.add({
          'isUser': false,
          'message': botMsg.message,
          'time': _formatTime(botNow),
        });
      });
      _chatService.saveMessage(botMsg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Style AI Advisor'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.wb_sunny_outlined), onPressed: () async {
            final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
            if (uid == null) return;
            await HistoryService().logEvent(uid, 'chat_action', {'action': 'toggle_theme'});
          }),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () async {
            final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
            if (uid == null) return;
            await HistoryService().logEvent(uid, 'chat_action', {'action': 'more_menu'});
          }),
        ],
      ),
      body: Column(
        children: [
          // Suggestion Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildChip('Outfit ideas for casual weekend'),
                _buildChip('Hairstyle for wedding'),
                _buildChip('Summer trends'),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  message: msg['message'],
                  isUser: msg['isUser'],
                  time: msg['time'],
                );
              },
            ),
          ),

          // Input Area
          GlassContainer(
            borderRadius: 0,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white70),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white70),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask about fashion...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF673AB7), AppColors.primaryAccent]),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
