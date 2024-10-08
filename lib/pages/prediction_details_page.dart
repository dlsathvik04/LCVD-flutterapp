import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lcvd/api/chat.dart';
import 'package:lcvd/models/prediction_data.dart';
import 'package:lcvd/widgets/prediction_card.dart';

class PredictionDetailsPage extends StatefulWidget {
  final PredictionData predictionData;
  final int boxIndex;
  const PredictionDetailsPage({
    super.key,
    required this.predictionData,
    required this.boxIndex,
  });

  @override
  PredictionDetailsPageState createState() => PredictionDetailsPageState();
}

class PredictionDetailsPageState extends State<PredictionDetailsPage> {
  List<String> options = [
    'What is this disease?',
    'What are the possible cures?',
    'What causes this disease?',
    'What are the common symptoms?',
    'What is the traditional diagnosis?',
    'What are the preventive measures?',
  ];

  Box<PredictionData>? predictionBox;
  late List<String> messages;

  @override
  void initState() {
    super.initState();
    predictionBox = Hive.box<PredictionData>('predictionBox');
    messages = predictionBox!.getAt(widget.boxIndex)!.chat!;
  }

  bool isBotResponding = false;

  void setMessages() {
    var current = predictionBox!.getAt(widget.boxIndex);
    current!.chat = messages;
    predictionBox!.putAt(widget.boxIndex, current);
  }

  void _sendMessage(String message) async {
    setState(() {
      messages.add(message);
      setMessages();
      messages.add("Loading...");
      isBotResponding = true;
    });

    try {
      String? response = await getChatResponse(message, widget.predictionData.prediction!);
      setState(() {
        messages[messages.length - 1] = response!;
        isBotResponding = false;
        setMessages();
      });
    } catch (e) {
      setState(() {
        print(e);
        messages[messages.length - 1] = e.toString();
        isBotResponding = false;
        setMessages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Column(
        children: <Widget>[
          PredictionCard(
              predictionData: widget.predictionData,
              active: false,
              boxIndex: widget.boxIndex),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + 1, // +1 for options
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  // Display chat messages
                  bool isUserMessage = index % 2 == 0;
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 5 / 6),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Theme.of(context).colorScheme.surfaceContainerHigh
                              : Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          messages[index],
                          style: TextStyle(
                            color: isUserMessage
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Display options after the last message
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: widget.predictionData.prediction == "Healthy" 
                    ? <Widget>[] 
                    : options.map((option) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 115, 121,
                                126), // Slightly darker color than messages
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            onTap: isBotResponding
                                ? null
                                : () => _sendMessage(option),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: isBotResponding
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
