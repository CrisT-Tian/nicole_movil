import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://nicoleia.servehttp.com:90/v1/chat/completions";

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer lm-studio", // tu backend sí pide esta clave
      },
      body: jsonEncode({
        "model": "meta-llama-3.1-8b-instruct", // el modelo exacto de tu backend
        "messages": [
          {"role": "user", "content": message},
        ],
        "temperature": 0.3,
        "max_tokens": 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Error al conectar con IA: ${response.statusCode}");
    }
  }
}
