import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/services/marker_service.dart';
import 'package:mapbox_task/utility/marker_helper.dart';

class MapProvider extends ChangeNotifier {
  List<Stores> stores = [];
  bool isLoading = false;
  String? error;
  
  // Save annotation managers for later use
  mb.PointAnnotationManager? pointAnnotationManager;
  mb.PointAnnotationManager? clusterAnnotationManager;


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
        stores = storeModel.stores!;
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
  

}
