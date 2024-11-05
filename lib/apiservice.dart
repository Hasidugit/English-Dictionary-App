// api.dart
import 'dart:convert';

import 'package:flutter_application_dictionary_wordcollection/responsemodel.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<ResponseModel?> fetchWordMeaning(String word) async {
    final response =
        await http.get(Uri.parse('https://api.example.com/define?word=$word'));

    if (response.statusCode == 200) {
      return ResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load meaning');
    }
  }
}
