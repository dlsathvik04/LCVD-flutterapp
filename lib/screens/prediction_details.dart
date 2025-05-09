import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lcvd/models/prediction.dart';
import 'package:lcvd/models/question.dart';
// TODO : Uncomment to add chat functionality
import 'package:lcvd/screens/chat.dart';
import 'package:lcvd/services/faq_service.dart';
import 'package:lcvd/services/prediction_service.dart';
import 'package:lcvd/widgets/expandable_data.dart';
import 'package:lcvd/widgets/prediction_data.dart';

class PredictionDetailsPage extends StatefulWidget {
  final Prediction prediction;
  const PredictionDetailsPage({super.key, required this.prediction});

  @override
  State<PredictionDetailsPage> createState() => _PredictionDetailsPageState();
}

class _PredictionDetailsPageState extends State<PredictionDetailsPage> {
  // Example function to get predefined strings (replace with your own implementation)

  // Set<String> _getPredefinedStrings() {
  //   return {'Case 1', 'Case 2', 'Case 3'};
  // }

  // TODO: uncomment to add adding to case functionality
  // void _handleAddToCase(Prediction prediction) async {
  //   final selectedString = await _showStringSelectionDialog(context);
  //   if (selectedString != null) {
  //     // Do something with the selected or newly created string
  //     print('Selected String: $selectedString');
  //   }
  // }

  // Future<String?> _showStringSelectionDialog(BuildContext context) {
  //   final Set<String> predefinedStrings = _getPredefinedStrings();
  //   final TextEditingController textController = TextEditingController();
  //   String? selectedString;

  //   return showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select or create a case'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButtonFormField<String>(
  //               items: predefinedStrings
  //                   .map((String value) => DropdownMenuItem<String>(
  //                         value: value,
  //                         child: Text(value),
  //                       ))
  //                   .toList(),
  //               onChanged: (String? newValue) {
  //                 setState(() {
  //                   selectedString = newValue;
  //                 });
  //               },
  //               decoration: InputDecoration(
  //                 labelText: 'Select an existing case',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12.0),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16), // Space between fields
  //             TextField(
  //               controller: textController,
  //               decoration: InputDecoration(
  //                 labelText: 'Create a new case',
  //                 hintText: 'Enter new case name',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12.0),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Cancel the dialog
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Use new input or selected string
  //               if (textController.text.isNotEmpty) {
  //                 selectedString = textController.text;
  //               }
  //               Navigator.of(context).pop(selectedString);
  //             },
  //             child: const Text('Submit'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<Question> questions = FaqService.getQuestions(widget.prediction);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        // TODO: Add to case action button
        // actions: [
        //   IconButton(
        //     onPressed: () => _handleAddToCase(widget.prediction),
        //     icon: const Icon(Icons.create_new_folder_outlined),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          FutureBuilder<File?>(
            future: PredictionService.loadImageFile(widget.prediction),
            builder: (context, snapshot) {
              double width = MediaQuery.of(context).size.width;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: width,
                  height: width * 0.75,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return SizedBox(
                  width: width,
                  height: width * 0.75,
                  child: const Center(child: Text('Error loading image')),
                );
              } else {
                return ClipRRect(
                  // borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    width: width,
                    height: width * 0.75,
                    child: Image.file(snapshot.data!, fit: BoxFit.cover),
                  ),
                );
              }
            },
          ),
          PredictionDataWidget(prediction: widget.prediction),
          QuestionGroup(
            questions: questions,
          )
        ]),
      ),
      // TODO : Uncomment to add chat functionality
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                prediction: widget.prediction,
              ),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
