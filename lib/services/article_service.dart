import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ArticleService {
  static const String baseUrl = 'http://127.0.0.1:8090';
  static const String collection = 'articles';

  // Singleton pattern
  static final ArticleService _instance = ArticleService._internal();
  factory ArticleService() => _instance;
  ArticleService._internal();

  // Get all articles
  Future<List<Article>> getAllArticles({
    int page = 1,
    int perPage = 50,
    String sort = '-created',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/collections/$collection/records?page=$page&perPage=$perPage&sort=$sort'
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  // Get single article by ID
  Future<Article> getArticleById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/api/collections/$collection/records/$id');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Article.fromJson(data);
      } else {
        throw Exception('Failed to load article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching article: $e');
    }
  }

  // Search articles
  Future<List<Article>> searchArticles(String query) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/collections/$collection/records?filter=(title~"$query"||description~"$query"||content~"$query")&sort=-created'
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching articles: $e');
    }
  }

  // Get articles by category
  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/collections/$collection/records?filter=(category="$category")&sort=-created'
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load articles by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles by category: $e');
    }
  }

  // Helper method to get base URL for images
  String get imageBaseUrl => baseUrl;
}
