import 'package:lcvd/api/endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getChatResponse(String prompt, String disease) async {
  var chatURL = await EndPointsProvider.getChatURL();

  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer no-key',
  };

  var body = jsonEncode({
    "class_name": disease,
    "history": [],
    "prompt": prompt,
  });

  var response = await http.post(
    Uri.parse(chatURL),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    print('Received chat response successfully');
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse['response'];
  } else {
    print('Error: ${response.statusCode}');
    throw Exception('Failed to get chat response');
  }
}
