import 'dart:convert';

class SearchPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeType;

  SearchPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeType,
  });

  factory SearchPlace.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;
    
    String name = '';
    String address = '';
    
    if (json.containsKey('text')) {
      name = json['text'] as String;
    }
    
    if (json.containsKey('place_name')) {
      address = json['place_name'] as String;
    }

    return SearchPlace(
      id: json['id'] as String,
      name: name,
      address: address,
      latitude: coordinates[1], // Mapbox returns [longitude, latitude]
      longitude: coordinates[0],
      placeType: json['place_type'] != null && (json['place_type'] as List).isNotEmpty
          ? (json['place_type'] as List)[0] as String
          : null,
    );
  }
}

class SearchResults {
  final List<SearchPlace> places;

  SearchResults({required this.places});

  factory SearchResults.fromJson(String str) {
    final jsonData = json.decode(str);
    final features = jsonData['features'] as List;
    final places = features.map((place) => SearchPlace.fromJson(place)).toList();
    return SearchResults(places: places);
  }
} 