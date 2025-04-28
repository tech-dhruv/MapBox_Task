import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/models/customer_model.dart';
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/utility/marker_helper.dart';

class MapProvider extends ChangeNotifier {
  List<Stores> stores = [];
  List<Stores> bronzeStores = [];
  List<Stores> silverStores = [];
  List<Stores> goldStores = [];
  
  List<Customer> customers = [];
  
  bool isLoading = false;
  String? error;
  
  mb.PointAnnotationManager? pointAnnotationManager;
  mb.PointAnnotationManager? bronzeAnnotationManager;
  mb.PointAnnotationManager? silverAnnotationManager;
  mb.PointAnnotationManager? goldAnnotationManager;
  mb.PointAnnotationManager? customerAnnotationManager;

  bool showBronzeStores = true;
  bool showSilverStores = true;
  bool showGoldStores = true;
  bool showCustomers = true;

  Future<void> fetchStores() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final String response = await rootBundle.loadString('lib/raw_data/anonymized_stores.json');
      
      final storeModel = storeModelFromJson(response);
      
      if (storeModel.stores != null) {
        stores = storeModel.stores!.take(100).toList();
        _categorizeStoresByTier();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchCustomers() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final String response = await rootBundle.loadString('lib/raw_data/anonymized_customers.json');
      
      final customerModel = customerModelFromJson(response);
      
      if (customerModel.customers != null) {
        customers = customerModel.customers!.take(50).toList();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
  
  void _categorizeStoresByTier() {
    bronzeStores.clear();
    silverStores.clear();
    goldStores.clear();
    
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
  
  void toggleCustomers() {
    showCustomers = !showCustomers;
    notifyListeners();
  }
}
