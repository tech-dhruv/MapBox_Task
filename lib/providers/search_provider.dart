import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/models/search_place_model.dart';
import 'package:mapbox_task/utility/mapbox_search_service.dart';

class SearchProvider extends ChangeNotifier {
  // Search state variables
  List<SearchPlace> _searchResults = [];
  SearchPlace? _selectedPlace;
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Getters
  List<SearchPlace> get searchResults => _searchResults;
  SearchPlace? get selectedPlace => _selectedPlace;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  
  // Set search query and perform search
  void setSearchQuery(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    notifyListeners();
    
    // Use debounced search
    MapboxSearchService.searchPlacesWithDebounce(query, (places) {
      _searchResults = places;
      _isSearching = false;
      notifyListeners();
    });
  }
  
  // Select a place from search results
  void selectPlace(SearchPlace place) {
    _selectedPlace = place;
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
  
  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
  
  // Clear selected place
  void clearSelectedPlace() {
    _selectedPlace = null;
    notifyListeners();
  }
  
  // Get camera options to fly to a selected place
  mb.CameraOptions getCameraOptionsForPlace(SearchPlace place) {
    return mb.CameraOptions(
      center: mb.Point(
        coordinates: mb.Position(
          place.longitude,
          place.latitude,
        ),
      ),
      zoom: 15,
      bearing: 0,
      pitch: 0,
    );
  }
} 