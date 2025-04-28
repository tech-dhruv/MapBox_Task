import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_task/models/search_place_model.dart';

class MapboxSearchService {
  static String get accessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  
  static const String baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  
  // Debouncer for handling search queries
  static final _debouncer = _Debouncer(milliseconds: 500);
  
  /// Search for places matching the query text
  static Future<List<SearchPlace>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) {
      return [];
    }
    
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/$query.json?access_token=$accessToken&autocomplete=true&limit=5&types=place,address,poi,locality,region'
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final results = SearchResults.fromJson(response.body);
        return results.places;
      } else {
        throw Exception('Failed to search places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }
  
  /// Search with debounce to avoid excessive API calls when typing
  static void searchPlacesWithDebounce(
    String query, 
    Function(List<SearchPlace>) onResult
  ) {
    _debouncer.run(() async {
      final places = await searchPlaces(query);
      onResult(places);
    });
  }
}

// Utility class for debouncing API calls
class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
} 