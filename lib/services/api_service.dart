import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dish.dart';

class ApiService {
  // Android emulator uses 10.0.2.2 to reach host machine localhost.
  // iOS simulator and web can use localhost directly.
  // Physical devices need the Mac's actual local IP.
  static String get _host {
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get _base => 'http://$_host:3000/api';

  static Future<List<Dish>> searchByIngredients(List<String> ingredients) async {
    final response = await http.post(
      Uri.parse('$_base/dishes/search/ingredients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).map((d) => Dish.fromJson(d)).toList();
    }
    throw Exception('Failed to search by ingredients');
  }

  static Future<List<Dish>> searchByFeeling(Map<String, dynamic> answers) async {
    final response = await http.post(
      Uri.parse('$_base/dishes/search/feeling'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(answers),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).map((d) => Dish.fromJson(d)).toList();
    }
    throw Exception('Failed to search by feeling');
  }

  static Future<List<Dish>> searchByRegion(String region) async {
    final response = await http.get(Uri.parse('$_base/dishes/region/$region'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).map((d) => Dish.fromJson(d)).toList();
    }
    throw Exception('Failed to search by region');
  }

  static Future<Dish> getRandomDish() async {
    final response = await http.get(Uri.parse('$_base/dishes/random'));
    if (response.statusCode == 200) {
      return Dish.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get random dish');
  }
}
