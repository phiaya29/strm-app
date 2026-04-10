import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resource_post.dart';

class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<ResourcePost>> fetchPosts() async {
    try {
      final response = await http
        .get(Uri.parse('$_baseUrl/posts?_limit=10'))
        .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((j) => ResourcePost.fromJson(j)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on Exception {
      rethrow;
    }
  }
}