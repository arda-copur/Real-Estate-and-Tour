import 'package:estate/providers/auth_provider.dart';
import 'package:estate/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

class EstateBotScreen extends StatefulWidget {
  const EstateBotScreen({super.key});

  @override
  State<EstateBotScreen> createState() => _EstateBotScreenState();
}

class _EstateBotScreenState extends State<EstateBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  static const _apiKey = 'GEMINI_API_KEY';

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Merhaba! Ben Seyahat Asistanınız. Size aklınızdaki tatil, seyahat veya deneyim adına rehberlik etmek için buradayım. Aklınızda bir plan var mı?',
      isUserMessage: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUserMessage: true));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
Sen bir tatil düzenleme, gezi turu ve  ev kiralama  uzmanısın. İnsanların sana yazdıklarına göre,
gezi turları, tatiller ve benzeri şeyler önereceksin.
Örnek olarak 'Size 3 günlük bir Antalya tatilinin iyi geleceğini düşünüyorum!' veya 'Bahçeli bir evde bir kaç gece konaklamak sizi iyi hissettirebilir.' gibi.
Türkçe yanıt ver. Neşeli ol ve yanıtlarını kısa tut.

Kullanıcı sorusu: $userMessage
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final botResponse =
          response.text ?? 'Üzgünüm, şu anda yanıt veremiyorum.';

      setState(() {
        _messages.add(ChatMessage(text: botResponse, isUserMessage: false));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Üzgünüm, bir hata oluştu: ${e.toString()}',
          isUserMessage: false,
        ));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                  userImage: user?.profileImage,
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/estate_bot.png',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tarif Asistanı yazıyor...'),
                ],
              ),
            ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppTheme.lightTheme.primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? userImage;

  const MessageBubble({
    super.key,
    required this.message,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUserMessage) ...[
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/estate_bot.png',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUserMessage
                    ? AppTheme.lightTheme.primaryColor.withOpacity(0.8)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUserMessage ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  userImage != null ? NetworkImage(userImage!) : null,
              backgroundColor: Colors.grey[300],
              child: userImage == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
