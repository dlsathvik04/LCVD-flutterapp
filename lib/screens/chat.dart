import 'package:flutter/material.dart';
import 'package:lcvd/api/language.dart';
import 'package:lcvd/models/prediction.dart';
import 'package:lcvd/services/prediction_service.dart';

class ChatPage extends StatefulWidget {
  final Prediction prediction;
  const ChatPage({super.key, required this.prediction});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  // Function to send a message and get a response from the chatbot
  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      widget.prediction.chat ??= [];
      widget.prediction.chat!.add(userMessage);
      _isSending = true;
    });

    try {
      String? botResponse = await getChatResponse(
          userMessage, widget.prediction.prediction ?? "healthy");

      setState(() {
        widget.prediction.chat!.add(botResponse ?? "ERROR TRY AGAIN");
        PredictionService.updatePrediction(widget.prediction);
      });
    } catch (e) {
      setState(() {
        widget.prediction.chat!
            .add("Error: Could not get response from chatbot.");
        PredictionService.updatePrediction(widget.prediction);
      });
    } finally {
      setState(() {
        _isSending = false;
        _messageController.clear();
      });
    }
  }

  // Widget to display a single chat message (user or bot)
  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.normal, // Same font weight as hint text
            color: isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.prediction.chat?.length ?? 0,
              itemBuilder: (context, index) {
                final message = widget.prediction.chat![index];
                final isUser = index.isEven;
                return _buildChatBubble(message, isUser);
              },
            ),
          ),
          if (_isSending) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null, // Allow multiple lines
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      hintText: "Type your message...",
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6), // Lighter color
                        fontWeight: FontWeight
                            .normal, // Same font weight as chat messages
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Fully rounded corners
                        borderSide: BorderSide.none,
                      ),
                    ),
                    enabled: !_isSending,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _isSending
                      ? null
                      : () {
                          final userMessage = _messageController.text.trim();
                          if (userMessage.isNotEmpty) {
                            _sendMessage(userMessage);
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
