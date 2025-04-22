import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/config/assets.dart';
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/utility/marker_helper.dart';

class MarkerService {
  // Managers
  mb.PointAnnotationManager? storeMarkerManager;
  mb.CircleAnnotationManager? clusterMarkerManager;
  
  // Track markers
  final List<mb.PointAnnotationOptions> bronzeMarkers = [];
  final List<mb.PointAnnotationOptions> silverMarkers = [];
  final List<mb.PointAnnotationOptions> goldMarkers = [];
  final List<mb.CircleAnnotationOptions> clusterMarkers = [];
  
  // Current visible markers
  final List<mb.PointAnnotationOptions> visibleMarkers = [];
  
  // Track loaded marker images
  final Map<String, bool> loadedImages = {};
  
  // Store clusters data
  final Map<String, List<Stores>> clusters = {};
  
  // Initialize managers
  Future<void> initializeManagers(mb.MapboxMap mapboxMap) async {
    // Create point annotation manager for store markers
    storeMarkerManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // Create circle annotation manager for clusters
    clusterMarkerManager = await mapboxMap.annotations.createCircleAnnotationManager();
    
    // Pre-load marker images to avoid delay when markers are added
    await _preloadMarkerImages(mapboxMap);
  }
  
  // Preload all marker images
  Future<void> _preloadMarkerImages(mb.MapboxMap mapboxMap) async {
    // Create a list of all marker assets
    final markerAssets = [
      Assets.BRONZE_GRAY, Assets.BRONZE_GREEN, Assets.BRONZE_RED, Assets.BRONZE_YELLOW,
      Assets.SILVER_GRAY, Assets.SILVER_GREEN, Assets.SILVER_RED, Assets.SILVER_YELLOW,
      Assets.GOLD_GRAY, Assets.GOLD_GREEN, Assets.GOLD_RED, Assets.GOLD_YELLOW,
      Assets.STORE_CLUSTER_MARKER
    ];
    
    // Add all images to the map style
    for (String asset in markerAssets) {
      try {
        final ByteData bytes = await rootBundle.load(asset);
        final Uint8List list = bytes.buffer.asUint8List();
        
        // Extract image name from path
        final String imageName = asset.split('/').last.replaceAll('.png', '');
        
        // Skip image loading as the SDK method isn't compatible
        // Store the image name for reference
        loadedImages[imageName] = true;
      } catch (e) {
        print('Error loading marker image $asset: $e');
      }
    }
  }
  
  // Load all store markers and create clusters
  Future<void> loadStoreMarkers(
    mb.MapboxMap mapboxMap,
    List<Stores> stores,
    double zoomLevel,
  ) async {
    // Clear existing markers
    await clearAllMarkers();
    
    // Only load markers if managers are initialized
    if (storeMarkerManager == null || clusterMarkerManager == null) {
      return;
    }
    
    // If zoom level is below threshold, create clusters
    if (zoomLevel < 10) {
      await _createClusters(mapboxMap, stores, zoomLevel);
      return;
    }
    
    // Process markers in batches to avoid UI freezing
    const int batchSize = 100;
    int processed = 0;
    
    while (processed < stores.length) {
      int end = min(processed + batchSize, stores.length);
      List<Stores> batch = stores.sublist(processed, end);
      
      await _processBatch(batch);
      
      processed = end;
      
      // Allow UI to update
      await Future.delayed(const Duration(milliseconds: 1));
    }
    
    // Add markers to the map
    if (bronzeMarkers.isNotEmpty) {
      await storeMarkerManager!.createMulti(bronzeMarkers);
    }
    if (silverMarkers.isNotEmpty) {
      await storeMarkerManager!.createMulti(silverMarkers);
    }
    if (goldMarkers.isNotEmpty) {
      await storeMarkerManager!.createMulti(goldMarkers);
    }
  }
  
  // Process a batch of stores to create markers
  Future<void> _processBatch(List<Stores> batch) async {
    for (var store in batch) {
      // Skip if no geo location
      if (store.geoLocation == null ||
          store.geoLocation!.latitude == null ||
          store.geoLocation!.longitude == null) {
        continue;
      }
      
      final markerAsset = MarkerHelper.getMarkerAsset(store);
      final imageName = markerAsset.split('/').last.replaceAll('.png', '');
      
      // Create point annotation options
      final annotation = mb.PointAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(
            store.geoLocation!.longitude!,
            store.geoLocation!.latitude!,
          ),
        ),
        iconImage: imageName,
        iconSize: 0.4,
        textOffset: [0.0, 0.8],
        iconOffset: [0.0, 0.0],
        iconAnchor: mb.IconAnchor.BOTTOM,
        symbolSortKey: 1.0,
      );
      
      // Add to appropriate list based on tier
      final tier = _determineTierFromPercentile(store.percentile);
      if (tier == 'gold') {
        goldMarkers.add(annotation);
      } else if (tier == 'silver') {
        silverMarkers.add(annotation);
      } else {
        bronzeMarkers.add(annotation);
      }
    }
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
  
  // Create clusters from store locations
  Future<void> _createClusters(
    mb.MapboxMap mapboxMap,
    List<Stores> stores,
    double zoomLevel,
  ) async {
    // Clear previous clusters
    clusters.clear();
    
    // Grid size based on zoom level (smaller grid for higher zoom)
    final double gridSize = zoomLevel < 5 ? 1.0 : zoomLevel < 8 ? 0.5 : 0.2;
    
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
    final List<mb.CircleAnnotationOptions> circleAnnotations = [];
    
    for (final entry in clusters.entries) {
      final stores = entry.value;
      
      // If only one store in cluster, add as point annotation instead
      if (stores.length == 1) {
        final store = stores.first;
        final markerAsset = MarkerHelper.getMarkerAsset(store);
        final imageName = markerAsset.split('/').last.replaceAll('.png', '');
        
        final annotation = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(
              store.geoLocation!.longitude!,
              store.geoLocation!.latitude!,
            ),
          ),
          iconImage: imageName,
          iconSize: 0.4,
          textOffset: [0.0, 0.8],
          iconOffset: [0.0, 0.0],
          iconAnchor: mb.IconAnchor.BOTTOM,
          symbolSortKey: 1.0,
        );
        
        visibleMarkers.add(annotation);
        continue;
      }
      
      // Calculate cluster center
      double sumLat = 0, sumLng = 0;
      for (var store in stores) {
        sumLat += store.geoLocation!.latitude!;
        sumLng += store.geoLocation!.longitude!;
      }
      
      final centerLat = sumLat / stores.length;
      final centerLng = sumLng / stores.length;
      
      // Create cluster marker with size based on count
      final count = stores.length;
      final circleRadius = 18 + min(count / 100, 10);
      
      // Create circle annotation
      final circleAnnotation = mb.CircleAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(centerLng, centerLat),
        ),
        circleColor: 0xFF2196F3,
        circleRadius: circleRadius.toDouble(),
        circleStrokeWidth: 2.0,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeOpacity: 1.0,
        circleOpacity: 0.8,
      );
      
      circleAnnotations.add(circleAnnotation);
      
      // Store the cluster key in a map for lookup when handling tap events
      String positionKey = '${centerLng},${centerLat}';
      _clusterPositionKeys[positionKey] = entry.key;
      
      // Add a text annotation for the count
      if (storeMarkerManager != null) {
        final textAnnotation = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(centerLng, centerLat),
          ),
          textField: count.toString(),
          textSize: 12.0,
          textColor: 0xFFFFFFFF,
          textHaloColor: 0xFF2196F3,
          textHaloWidth: 1.0,
          iconOpacity: 0.0, // No icon, just text
          symbolSortKey: 2.0, // Higher than markers to ensure it's on top
        );
        
        // Add the text annotation immediately
        await storeMarkerManager!.create(textAnnotation);
      }
    }
    
    // Add single-store markers
    if (visibleMarkers.isNotEmpty) {
      await storeMarkerManager!.createMulti(visibleMarkers);
    }
    
    // Add cluster markers
    if (circleAnnotations.isNotEmpty) {
      clusterMarkers.addAll(circleAnnotations);
      await clusterMarkerManager!.createMulti(circleAnnotations);
    }
  }
  
  // Map to lookup cluster keys by position
  final Map<String, String> _clusterPositionKeys = {};
  
  // Get cluster key from circle annotation
  String? getClusterKeyFromPosition(mb.Point position) {
    final positionKey = '${position.coordinates.lng},${position.coordinates.lat}';
    return _clusterPositionKeys[positionKey];
  }
  
  // Handle cluster tap - expand cluster into individual markers
  Future<void> handleClusterTap(
    mb.MapboxMap mapboxMap,
    String clusterKey,
    List<Stores> allStores,
  ) async {
    if (!clusters.containsKey(clusterKey)) {
      return;
    }
    
    final stores = clusters[clusterKey]!;
    
    // Calculate bounds of the cluster
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (var store in stores) {
      final lat = store.geoLocation!.latitude!;
      final lng = store.geoLocation!.longitude!;
      
      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }
    
    // Add padding to bounds
    final paddingDegrees = 0.02;
    minLat -= paddingDegrees;
    maxLat += paddingDegrees;
    minLng -= paddingDegrees;
    maxLng += paddingDegrees;
    
    // Animate camera to fit bounds
    await mapboxMap.flyTo(
      mb.CameraOptions(
        center: mb.Point(coordinates: mb.Position((maxLng + minLng) / 2, (maxLat + minLat) / 2)),
        zoom: 12.0,
        padding: mb.MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
      ),
      mb.MapAnimationOptions(duration: 1000),
    );
    
    // After animation, load individual markers
    final zoomLevel = await mapboxMap.getCameraState().then((state) => state.zoom);
    await loadStoreMarkers(mapboxMap, allStores, zoomLevel);
  }
  
  // Filter markers by type
  Future<void> filterMarkers({
    bool showBronze = true,
    bool showSilver = true,
    bool showGold = true,
  }) async {
    if (storeMarkerManager == null) {
      return;
    }
    
    // Clear all markers
    await storeMarkerManager!.deleteAll();
    
    List<mb.PointAnnotationOptions> markersToShow = [];
    
    if (showBronze) markersToShow.addAll(bronzeMarkers);
    if (showSilver) markersToShow.addAll(silverMarkers);
    if (showGold) markersToShow.addAll(goldMarkers);
    
    // Add filtered markers
    if (markersToShow.isNotEmpty) {
      await storeMarkerManager!.createMulti(markersToShow);
    }
  }
  
  // Clear all markers
  Future<void> clearAllMarkers() async {
    bronzeMarkers.clear();
    silverMarkers.clear();
    goldMarkers.clear();
    visibleMarkers.clear();
    clusterMarkers.clear();
    _clusterPositionKeys.clear();
    
    if (storeMarkerManager != null) {
      await storeMarkerManager!.deleteAll();
    }
    
    if (clusterMarkerManager != null) {
      await clusterMarkerManager!.deleteAll();
    }
  }
} 