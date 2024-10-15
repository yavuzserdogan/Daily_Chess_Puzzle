import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PuzzleRepository {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<Map<String, String>> getFenAndPgn() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fen = data['fen'];
        String pgn = data['pgn'];
        String url = data['url'];
        return {'fen': fen, 'pgn': pgn, 'url': url};
      } else {
        throw Exception('Failed to load puzzle');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
