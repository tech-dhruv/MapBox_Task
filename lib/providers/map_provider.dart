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
  
  // Customer data
  List<Customer> customers = [];
  
  bool isLoading = false;
  String? error;
  
  // Save annotation managers for later use
  mb.PointAnnotationManager? pointAnnotationManager;
  mb.PointAnnotationManager? bronzeAnnotationManager;
  mb.PointAnnotationManager? silverAnnotationManager;
  mb.PointAnnotationManager? goldAnnotationManager;
  mb.PointAnnotationManager? customerAnnotationManager;

  // Track visibility of each category
  bool showBronzeStores = true;
  bool showSilverStores = true;
  bool showGoldStores = true;
  bool showCustomers = true;

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
  
  Future<void> fetchCustomers() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Load the JSON file from assets
      print('Attempting to load customer data file...');
      final String response = await rootBundle.loadString('lib/raw_data/anonymized_customers.json');
      print('Customer data file loaded, length: ${response.length} characters');
      
      // Parse the JSON string
      print('Parsing customer JSON data...');
      final customerModel = customerModelFromJson(response);
      
      // Update the customers list - take only 50 as requested
      if (customerModel.customers != null) {
        print('Found ${customerModel.customers!.length} customers in the data');
        customers = customerModel.customers!.take(50).toList();
        print('Customers loaded: ${customers.length} (memory only, not displayed yet)');
      } else {
        print('No customers found in the data - customers list is null');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error loading customers: $e');
      print('Stack trace: ${StackTrace.current}');
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
  
  void toggleCustomers() {
    showCustomers = !showCustomers;
    notifyListeners();
  }
}
