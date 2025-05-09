import 'package:shared_preferences/shared_preferences.dart';

class EndPointsProvider {
  static const String _imagePredictionURL =
      "https://dlsathvik04-lcvd-vision.hf.space/predict";
  static const String _chatURL =
      "https://dlsathvik04-lcvd-language.hf.space/rag/direct";

  static Future<String> getImagePredictionURL() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String? res = sharedPreferences.getString("imagePredictionURL");
    if (res == null) {
      return _imagePredictionURL;
    } else {
      return res;
    }
  }

  static Future<String> getChatURL() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String? res = sharedPreferences.getString("chatURL");
    if (res == null) {
      return _chatURL;
    } else {
      return res;
    }
  }
}
