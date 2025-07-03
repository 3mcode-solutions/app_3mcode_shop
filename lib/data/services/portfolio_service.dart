import 'dart:convert';
import 'package:http/http.dart' as http;

class PortfolioService {
  static const String baseUrl = 'https://3mcode-solutions.com/wp-json/wp/v2';

  /// جلب التصنيفات الخاصة بالمشاريع
  static Future<List<ProjectCategory>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/project-cat'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ProjectCategory.fromJson(e)).toList();
    } else {
      throw Exception('فشل في جلب التصنيفات');
    }
  }

  /// جلب المشاريع (مع إمكانية الفلترة بالتصنيف)
  static Future<List<ProjectItem>> fetchProjects({int? categoryId}) async {
    String url = '$baseUrl/portfolio?_embed';
    if (categoryId != null) {
      url += '&project-cat=$categoryId';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ProjectItem.fromJson(e)).toList();
    } else {
      throw Exception('فشل في جلب المشاريع');
    }
  }
}

class ProjectCategory {
  final int id;
  final String name;

  ProjectCategory({required this.id, required this.name});

  factory ProjectCategory.fromJson(Map<String, dynamic> json) {
    return ProjectCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ProjectItem {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<int> categories;

  ProjectItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.categories,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    // جلب الصورة البارزة من _embedded
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'].isNotEmpty) {
      imageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
    }
    return ProjectItem(
      id: json['id'],
      title: json['title']['rendered'],
      description: json['excerpt']?['rendered'],
      imageUrl: imageUrl,
      categories: (json['project-cat'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }
} 