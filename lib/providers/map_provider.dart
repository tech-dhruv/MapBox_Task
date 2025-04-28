import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/utility/marker_helper.dart';

class MapProvider extends ChangeNotifier {
  List<Stores> stores = [];
  List<Stores> bronzeStores = [];
  List<Stores> silverStores = [];
  List<Stores> goldStores = [];
  
  bool isLoading = false;
  String? error;
  
  // Save annotation managers for later use
  mb.PointAnnotationManager? pointAnnotationManager;
  mb.PointAnnotationManager? bronzeAnnotationManager;
  mb.PointAnnotationManager? silverAnnotationManager;
  mb.PointAnnotationManager? goldAnnotationManager;

  // Track visibility of each category
  bool showBronzeStores = true;
  bool showSilverStores = true;
  bool showGoldStores = true;

  Future<void> fetchStores() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Load the JSON file from assets
      final String response = await rootBundle.loadString('lib/raw_data/anonymized_stores.json');
      
      // Parse the JSON string
      final storeModel = storeModelFromJson(response);
      
      // Update the stores list
      if (storeModel.stores != null) {
        stores = storeModel.stores!.take(100).toList();
        _categorizeStoresByTier();
        print('All stores loaded: ${stores.length} (memory only, not displayed yet)');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error loading stores: $e');
    }
  }
  
  void _categorizeStoresByTier() {
    // Clear existing lists
    bronzeStores.clear();
    silverStores.clear();
    goldStores.clear();
    
    // Categorize each store based on its tier
    for (var store in stores) {
      String tier = _determineTier(store.percentile);
      switch (tier) {
        case 'gold':
          goldStores.add(store);
          break;
        case 'silver':
          silverStores.add(store);
          break;
        case 'bronze':
        default:
          bronzeStores.add(store);
          break;
      }
    }
    
    print('Stores categorized - Bronze: ${bronzeStores.length}, Silver: ${silverStores.length}, Gold: ${goldStores.length}');
  }
  
  String _determineTier(double? percentile) {
    return MarkerHelper.determineTier(percentile);
  }
  
  void toggleBronzeStores() {
    showBronzeStores = !showBronzeStores;
    notifyListeners();
  }
  
  void toggleSilverStores() {
    showSilverStores = !showSilverStores;
    notifyListeners();
  }
  
  void toggleGoldStores() {
    showGoldStores = !showGoldStores;
    notifyListeners();
  }
}
