import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/models/stores_model.dart';

// Implementation of OnCircleAnnotationClickListener
class _CircleAnnotationClickListener extends mb.OnCircleAnnotationClickListener {
  final MapProvider provider;
  
  _CircleAnnotationClickListener(this.provider);
  
  @override
  bool onCircleAnnotationClick(mb.CircleAnnotation annotation) {
    // Find the cluster that was tapped
    if (annotation.geometry != null) {
      final position = annotation.geometry!;
      final positionKey = '${position.coordinates.lng},${position.coordinates.lat}';
      
      if (provider.clusterPositionKeys.containsKey(positionKey)) {
        final clusterKey = provider.clusterPositionKeys[positionKey]!;
        provider.handleClusterTap(position);
        return true; // Event was handled
      }
    }
    return false; // Event was not handled
  }
}

class MapProvider extends ChangeNotifier {
  List<Stores> stores = [];
  bool isLoading = false;
  String? error;
  
  // Map controller
  mb.MapboxMap? mapboxMap;
  double currentZoom = 10.0;
  
  // Filter states
  bool showBronzeStores = true;
  bool showSilverStores = true;
  bool showGoldStores = true;
  
  // Marker managers
  mb.PointAnnotationManager? pointAnnotationManager;
  mb.CircleAnnotationManager? circleAnnotationManager;
  
  // Lists to store markers by type
  final List<mb.PointAnnotationOptions> bronzeMarkers = [];
  final List<mb.PointAnnotationOptions> silverMarkers = [];
  final List<mb.PointAnnotationOptions> goldMarkers = [];
  final List<mb.CircleAnnotationOptions> clusterMarkers = [];
  
  // Track clusters
  final Map<String, List<Stores>> clusters = {};
  final Map<String, String> clusterPositionKeys = {};

  void setMapboxMap(mb.MapboxMap controller) {
    mapboxMap = controller;
    _initializeAnnotationManagers();
    notifyListeners();
  }

  Future<void> _initializeAnnotationManagers() async {
    if (mapboxMap != null) {
      // Create annotation managers
      pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
      circleAnnotationManager = await mapboxMap!.annotations.createCircleAnnotationManager();
      
      // Set up tap handler for circle annotations (clusters)
      if (circleAnnotationManager != null) {
        circleAnnotationManager!.addOnCircleAnnotationClickListener(_CircleAnnotationClickListener(this));
      }
    }
  }
  
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
      
      // Load markers if map is available
      if (mapboxMap != null) {
        await loadMarkers();
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
  
  Future<void> loadMarkers() async {
    if (mapboxMap == null || pointAnnotationManager == null) return;
    
    try {
      // Get current zoom level
      currentZoom = await mapboxMap!.getCameraState().then((state) => state.zoom);
      
      // Clear existing markers
      await _clearAllMarkers();
      
      // Show clusters if zoom level is below threshold
      if (currentZoom < 10) {
        await _createClusters();
      } else {
        await _loadIndividualMarkers();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading markers: $e');
    }
  }
  
  Future<void> _loadIndividualMarkers() async {
    if (pointAnnotationManager == null) return;
    
    bronzeMarkers.clear();
    silverMarkers.clear();
    goldMarkers.clear();
    
    // Process markers in batches to avoid UI freezing
    const int batchSize = 100;
    int processed = 0;
    
    while (processed < stores.length) {
      int end = processed + batchSize < stores.length ? processed + batchSize : stores.length;
      List<Stores> batch = stores.sublist(processed, end);
      
      for (var store in batch) {
        // Skip if no geo location
        if (store.geoLocation == null ||
            store.geoLocation!.latitude == null ||
            store.geoLocation!.longitude == null) {
          continue;
        }
        
        // Skip if filtered out
        final tier = _determineTierFromPercentile(store.percentile);
        if ((tier == 'gold' && !showGoldStores) ||
            (tier == 'silver' && !showSilverStores) ||
            (tier == 'bronze' && !showBronzeStores)) {
          continue;
        }
        
        // Create point annotation options
        final annotation = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(
              store.geoLocation!.longitude!,
              store.geoLocation!.latitude!,
            ),
          ),
          iconSize: 0.4,
        );
        
        // Add to appropriate list based on tier
        if (tier == 'gold') {
          goldMarkers.add(annotation);
        } else if (tier == 'silver') {
          silverMarkers.add(annotation);
        } else {
          bronzeMarkers.add(annotation);
        }
      }
      
      processed = end;
      
      // Allow UI to update
      await Future.delayed(const Duration(milliseconds: 1));
    }
    
    // Add markers to the map based on filters
    List<mb.PointAnnotationOptions> markersToShow = [];
    
    if (showBronzeStores) markersToShow.addAll(bronzeMarkers);
    if (showSilverStores) markersToShow.addAll(silverMarkers);
    if (showGoldStores) markersToShow.addAll(goldMarkers);
    
    if (markersToShow.isNotEmpty) {
      await pointAnnotationManager!.createMulti(markersToShow);
    }
  }
  
  Future<void> _createClusters() async {
    if (mapboxMap == null || 
        pointAnnotationManager == null || 
        circleAnnotationManager == null) return;
        
    // Clear previous clusters
    clusters.clear();
    clusterPositionKeys.clear();
    
    // Grid size based on zoom level (smaller grid for higher zoom)
    final double gridSize = currentZoom < 5 ? 1.0 : currentZoom < 8 ? 0.5 : 0.2;
    
    // Group stores into clusters based on proximity
    for (var store in stores) {
      if (store.geoLocation == null ||
          store.geoLocation!.latitude == null ||
          store.geoLocation!.longitude == null) {
        continue;
      }
      
      // Create a grid-based key for clustering
      final latGrid = (store.geoLocation!.latitude! / gridSize).floor() * gridSize;
      final lngGrid = (store.geoLocation!.longitude! / gridSize).floor() * gridSize;
      final clusterKey = '$latGrid-$lngGrid';
      
      // Add store to cluster
      if (!clusters.containsKey(clusterKey)) {
        clusters[clusterKey] = [];
      }
      clusters[clusterKey]!.add(store);
    }
    
    // Create circle annotations for clusters
    List<mb.CircleAnnotationOptions> circleAnnotations = [];
    
    for (final entry in clusters.entries) {
      final clusterStores = entry.value;
      
      // Filter cluster stores based on current filter settings
      final filteredStores = clusterStores.where((store) {
        final tier = _determineTierFromPercentile(store.percentile);
        return (tier == 'gold' && showGoldStores) ||
               (tier == 'silver' && showSilverStores) ||
               (tier == 'bronze' && showBronzeStores);
      }).toList();
      
      // If no stores match filter, skip this cluster
      if (filteredStores.isEmpty) continue;
      
      // Calculate cluster center
      double sumLat = 0, sumLng = 0;
      for (var store in filteredStores) {
        sumLat += store.geoLocation!.latitude!;
        sumLng += store.geoLocation!.longitude!;
      }
      
      final centerLat = sumLat / filteredStores.length;
      final centerLng = sumLng / filteredStores.length;
      
      // Create cluster marker with size based on count
      final circleSize = 20.0 + (filteredStores.length < 100 ? filteredStores.length / 10 : 10.0);
      
      // Create circle annotation
      final circleAnnotation = mb.CircleAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(centerLng, centerLat),
        ),
        circleRadius: circleSize,
        circleColor: 0xFF2196F3,
        circleStrokeWidth: 2.0,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeOpacity: 1.0,
        circleOpacity: 0.8,
      );
      
      circleAnnotations.add(circleAnnotation);
      clusterMarkers.add(circleAnnotation);
      
      // Store the cluster key for lookup when handling tap events
      final positionKey = '$centerLng,$centerLat';
      clusterPositionKeys[positionKey] = entry.key;
      
      // Add a text annotation for count
      final count = filteredStores.length.toString();
      final textAnnotation = mb.PointAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(centerLng, centerLat),
        ),
        textField: count,
        iconOpacity: 0.0,
        textColor: 0xFFFFFFFF,
        textSize: 14.0,
      );
      
      // Add text annotation
      await pointAnnotationManager!.create(textAnnotation);
    }
    
    // Add cluster markers
    if (circleAnnotations.isNotEmpty) {
      await circleAnnotationManager!.createMulti(circleAnnotations);
    }
  }
  
  Future<void> handleClusterTap(mb.Point position) async {
    if (mapboxMap == null) return;
    
    final positionKey = '${position.coordinates.lng},${position.coordinates.lat}';
    final clusterKey = clusterPositionKeys[positionKey];
    
    if (clusterKey == null || !clusters.containsKey(clusterKey)) {
      return;
    }
    
    // Zoom in to reveal individual markers
    await mapboxMap!.flyTo(
      mb.CameraOptions(
        center: position,
        zoom: 12.0,
      ),
      mb.MapAnimationOptions(duration: 1000),
    );
    
    // After animation, update the zoom level and load markers
    await Future.delayed(const Duration(milliseconds: 1000));
    await loadMarkers();
  }
  
  // Determine tier from percentile (same logic as in MarkerHelper)
  String _determineTierFromPercentile(double? percentile) {
    if (percentile == null) {
      return 'bronze';
    }
    
    if (percentile < 10) {
      return 'gold';
    } else if (percentile >= 10 && percentile <= 50) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }
  
  // Clear all markers
  Future<void> _clearAllMarkers() async {
    bronzeMarkers.clear();
    silverMarkers.clear();
    goldMarkers.clear();
    clusterMarkers.clear();
    
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();
    }
    
    if (circleAnnotationManager != null) {
      await circleAnnotationManager!.deleteAll();
    }
  }
  
  // Toggle filters
  void toggleBronzeStores() {
    showBronzeStores = !showBronzeStores;
    loadMarkers();
  }
  
  void toggleSilverStores() {
    showSilverStores = !showSilverStores;
    loadMarkers();
  }
  
  void toggleGoldStores() {
    showGoldStores = !showGoldStores;
    loadMarkers();
  }
  
  // Called when map camera changes (e.g., zoom changes)
  void onCameraChanged(dynamic event) {
    try {
      // Reload markers if needed (this will be triggered by the home screen)
      loadMarkers();
    } catch (e) {
      print('Error processing camera change: $e');
    }
  }
}
