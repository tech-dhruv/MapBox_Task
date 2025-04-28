import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/config/assets.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/text_style.dart';
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/providers/map_provider.dart';
import 'package:mapbox_task/utility/marker_helper.dart';
import 'package:mapbox_task/utility/toast_service.dart';
import 'package:mapbox_task/view/base/theme_button.dart';
import 'package:mapbox_task/view/base/theme_input_field.dart';
import 'package:mapbox_task/view/screens/home/filter_bottom_sheet.dart';
import 'package:mapbox_task/view/screens/no_internet/no_internet.dart';
import 'package:provider/provider.dart';

@RoutePage<String>()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  late ConnectivityProvider _connectivityProvider;
  late MapProvider _mapProvider;

  mb.MapboxMap? mapboxMapController;
  mb.PointAnnotationManager? bronzeAnnotationManager;
  mb.PointAnnotationManager? silverAnnotationManager;
  mb.PointAnnotationManager? goldAnnotationManager;
  
  StreamSubscription? userPositionStream;
  gl.Position? _currentPosition;
  bool _storesLoaded = false;
  
  // Cache for marker images to avoid reloading same assets
  final Map<String, Uint8List> _markerImageCache = {};
  bool _assetsPreloaded = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _setupPositionTracking();
      _connectivityProvider = Provider.of<ConnectivityProvider>(context);
      _mapProvider = Provider.of<MapProvider>(context);
      _connectivityProvider.initConnectivity(mounted);
      _connectivityProvider.connectivitySubscription = _connectivityProvider
          .connectivity.onConnectivityChanged
          .listen(_connectivityProvider.updateConnectionStatus);
      
      // Preload marker assets in the background
      _preloadMarkerAssets();
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to rotate the map once it's loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rotateMapToShowCompass();
    });
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    _markerImageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, provider, child) {
        return (provider.connectionStatus == ConnectivityResult.mobile ||
                provider.connectionStatus == ConnectivityResult.wifi ||
                provider.connectionStatus == ConnectivityResult.ethernet ||
                provider.connectionStatus == ConnectivityResult.vpn)
            ? SafeArea(
                bottom: true,
                top: true,
                child: Scaffold(
                  backgroundColor: ColorPallet.darkBlackColor,
                  body: Stack(
                    children: [
                      mb.MapWidget(
                        onMapCreated: _onMapCreated,
                        styleUri: mb.MapboxStyles.DARK,
                      ),
                      Positioned(
                        top: 15,
                        left: 10,
                        right: 10,
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: ThemeInputField(
                                  cursorColor: ColorPallet.whiteColor.withOpacity(0.6),
                                  textStyle: TextStyles.bodyText2(color: ColorPallet.whiteColor.withOpacity(0.8)),
                                  height: 50,
                                  hint: 'Search for a place',
                                  hintStyle: TextStyles.bodyText2(color: ColorPallet.whiteColor.withOpacity(0.6)),
                                  backgroundColor: ColorPallet.secondaryDarkBlackColor,
                                  showBorder: true,
                                  borderColor: ColorPallet.whiteColor,
                                )
                              ),
                              const SizedBox(width: 10),
                              Consumer<MapProvider>(
                                builder: (context, mapProvider, _) {
                                  // Count active filters
                                  int activeFilters = 0;
                                  if (mapProvider.showBronzeStores) activeFilters++;
                                  if (mapProvider.showSilverStores) activeFilters++;
                                  if (mapProvider.showGoldStores) activeFilters++;
                                  
                                  return Stack(
                                    children: [
                                      CCIconButton(
                                        buttonHeight: 50,
                                        buttonWidth: 50,
                                        shadow: false,
                                        onTap: () {
                                          _showFilterBottomSheet(context);
                                        },
                                        icon: Icon(Icons.filter_alt_outlined, color: ColorPallet.whiteColor),
                                      ),
                                      if (activeFilters > 0 && activeFilters < 3)
                                        Positioned(
                                          right: 5,
                                          top: 5,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: ColorPallet.secondaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$activeFilters',
                                              style: TextStyles.bodyText3(color: ColorPallet.whiteColor),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    heroTag: 'my_location',
                    shape: const CircleBorder(),
                    onPressed: _goToMyLocation,
                    backgroundColor: ColorPallet.secondaryColor.withOpacity(0.8),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const NoInternetScreen();
      },
    );
  }

  void _onMapCreated(mb.MapboxMap controller) async {
    try {
      setState(() {
        mapboxMapController = controller;
      });
      
      print('Map created successfully');
      
      // Configure basic map settings
      await mapboxMapController?.location.updateSettings(
        mb.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );
      
      // Configure compass settings
      await mapboxMapController?.compass.updateSettings(
        mb.CompassSettings(
          enabled: true,
          position: mb.OrnamentPosition.TOP_RIGHT,
          marginTop: 70.0,
          marginRight: 16.0,
          fadeWhenFacingNorth: false,
          opacity: 1.0,
        ),
      );
      
      // Configure scale bar settings
      await mapboxMapController?.scaleBar.updateSettings(
        mb.ScaleBarSettings(
          enabled: true,
          position: mb.OrnamentPosition.TOP_LEFT,
          marginTop: 70.0,
          marginLeft: 16.0,
        ),
      );
      
      // Wait for the map to fully render before adding markers
      await Future.delayed(const Duration(seconds: 1));
      
      // Initialize annotation managers
      await _initializeAnnotationManagers();
      
      // Start preloading assets in background
      _preloadMarkerAssets().then((_) {
        // Load stores and create markers once assets are preloaded
        _loadStoresAndCreateMarkers();
      });
    } catch (e) {
      print('Error in _onMapCreated: $e');
      ToastService.show('Error initializing map');
    }
  }

  Future<void> _initializeAnnotationManagers() async {
    try {
      if (mapboxMapController != null) {
        print('Initializing annotation managers');
        
        // Create separate annotation managers for each category
        final bronzeManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        final silverManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        final goldManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        
        setState(() {
          bronzeAnnotationManager = bronzeManager;
          silverAnnotationManager = silverManager;
          goldAnnotationManager = goldManager;
        });
        
        // Save to the provider for later use
        _mapProvider.bronzeAnnotationManager = bronzeManager;
        _mapProvider.silverAnnotationManager = silverManager;
        _mapProvider.goldAnnotationManager = goldManager;
        
        print('Annotation managers initialized successfully');
      }
    } catch (e) {
      print('Error initializing annotation managers: $e');
      ToastService.show('Error initializing map markers');
    }
  }

  Future<void> _loadStoresAndCreateMarkers() async {
    if (_storesLoaded) return;
    
    try {
      await _mapProvider.fetchStores();
      
      if (_mapProvider.stores.isNotEmpty) {
        await _createCategoryMarkers();
        
        setState(() {
          _storesLoaded = true;
        });
      }
    } catch (e) {
      print('Error in _loadStoresAndCreateMarkers: $e');
      ToastService.show('Failed to load store markers');
    }
  }

  Future<void> _preloadMarkerAssets() async {
    if (_assetsPreloaded) return;
    
    try {
      print('Preloading marker assets...');
      
      // List of all marker assets
      final List<String> markerAssets = [
        Assets.BRONZE_GRAY, Assets.BRONZE_GREEN, Assets.BRONZE_RED, Assets.BRONZE_YELLOW,
        Assets.SILVER_GRAY, Assets.SILVER_GREEN, Assets.SILVER_RED, Assets.SILVER_YELLOW,
        Assets.GOLD_GRAY, Assets.GOLD_GREEN, Assets.GOLD_RED, Assets.GOLD_YELLOW,
      ];
      
      // Load each asset into the cache
      for (final asset in markerAssets) {
        try {
          final ByteData data = await rootBundle.load(asset);
          final Uint8List bytes = data.buffer.asUint8List();
          _markerImageCache[asset] = bytes;
        } catch (e) {
          print('Error preloading asset $asset: $e');
        }
      }
      
      _assetsPreloaded = true;
      print('Marker assets preloaded successfully');
    } catch (e) {
      print('Error preloading marker assets: $e');
    }
  }

  Future<void> _createCategoryMarkers() async {
    try {
      // Create markers for each category if they should be visible
      if (_mapProvider.showBronzeStores) {
        await _createBronzeMarkers();
      }
      
      if (_mapProvider.showSilverStores) {
        await _createSilverMarkers();
      }
      
      if (_mapProvider.showGoldStores) {
        await _createGoldMarkers();
      }
    } catch (e) {
      print('Error creating category markers: $e');
    }
  }

  Future<void> _createBronzeMarkers() async {
    if (bronzeAnnotationManager == null || _mapProvider.bronzeStores.isEmpty) return;
    
    try {
      await _createMarkersForStores(_mapProvider.bronzeStores, bronzeAnnotationManager!);
      print('Created ${_mapProvider.bronzeStores.length} bronze markers');
    } catch (e) {
      print('Error creating bronze markers: $e');
    }
  }

  Future<void> _createSilverMarkers() async {
    if (silverAnnotationManager == null || _mapProvider.silverStores.isEmpty) return;
    
    try {
      await _createMarkersForStores(_mapProvider.silverStores, silverAnnotationManager!);
      print('Created ${_mapProvider.silverStores.length} silver markers');
    } catch (e) {
      print('Error creating silver markers: $e');
    }
  }

  Future<void> _createGoldMarkers() async {
    if (goldAnnotationManager == null || _mapProvider.goldStores.isEmpty) return;
    
    try {
      await _createMarkersForStores(_mapProvider.goldStores, goldAnnotationManager!);
      print('Created ${_mapProvider.goldStores.length} gold markers');
    } catch (e) {
      print('Error creating gold markers: $e');
    }
  }

  Future<void> _createMarkersForStores(List<Stores> stores, mb.PointAnnotationManager manager) async {
    try {
      // Wait for assets to be preloaded if possible
      if (!_assetsPreloaded) {
        await _preloadMarkerAssets();
      }
      
      // Limit the number of markers to avoid memory issues
      final storesToDisplay = stores.take(50).toList(); // Limit per category for better performance
      
      // Process markers in smaller batches to avoid overwhelming memory
      const int batchSize = 10;
      for (int i = 0; i < storesToDisplay.length; i += batchSize) {
        final int end = (i + batchSize < storesToDisplay.length) 
            ? i + batchSize 
            : storesToDisplay.length;
            
        final List<mb.PointAnnotationOptions> markerBatch = [];
        
        // Process the current batch
        for (int j = i; j < end; j++) {
          final store = storesToDisplay[j];
          
          if (store.geoLocation?.latitude == null || 
              store.geoLocation?.longitude == null ||
              store.id == null) {
            continue;
          }
          
          try {
            // Get the appropriate marker image based on store data
            final markerAsset = MarkerHelper.getMarkerAsset(store);
            
            // Use cached image if available, otherwise load it
            Uint8List? markerImageBytes = _markerImageCache[markerAsset];
            if (markerImageBytes == null) {
              final ByteData bytes = await rootBundle.load(markerAsset);
              markerImageBytes = bytes.buffer.asUint8List();
              _markerImageCache[markerAsset] = markerImageBytes;
            }
            
            // Create point annotation options with minimal properties
            final markerOption = mb.PointAnnotationOptions(
              geometry: mb.Point(
                coordinates: mb.Position(
                  store.geoLocation!.longitude!,
                  store.geoLocation!.latitude!,
                ),
              ),
              image: markerImageBytes,
              iconSize: 0.15, // Keep size small to reduce memory usage
            );
            
            markerBatch.add(markerOption);
          } catch (e) {
            print('Error creating marker for store ${store.id}: $e');
          }
        }
        
        // Add the batch of markers to the map
        if (markerBatch.isNotEmpty) {
          try {
            await manager.createMulti(markerBatch);
          } catch (e) {
            print('Error adding marker batch: $e');
          }
        }
        
        // Small delay to allow UI to update and prevent ANR
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error in _createMarkersForStores: $e');
    }
  }

  void _updateBronzeMarkers() async {
    try {
      if (bronzeAnnotationManager != null) {
        await bronzeAnnotationManager!.deleteAll();
        
        if (_mapProvider.showBronzeStores) {
          await _createBronzeMarkers();
        }
      }
    } catch (e) {
      print('Error updating bronze markers: $e');
    }
  }

  void _updateSilverMarkers() async {
    try {
      if (silverAnnotationManager != null) {
        await silverAnnotationManager!.deleteAll();
        
        if (_mapProvider.showSilverStores) {
          await _createSilverMarkers();
        }
      }
    } catch (e) {
      print('Error updating silver markers: $e');
    }
  }

  void _updateGoldMarkers() async {
    try {
      if (goldAnnotationManager != null) {
        await goldAnnotationManager!.deleteAll();
        
        if (_mapProvider.showGoldStores) {
          await _createGoldMarkers();
        }
      }
    } catch (e) {
      print('Error updating gold markers: $e');
    }
  }

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastService.show('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }
    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        ToastService.show('Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == gl.LocationPermission.deniedForever) {
      ToastService.show('Location permissions are denied forever.');
      return Future.error('Location permissions are denied forever.');
    }

    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 1000,
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((gl.Position? position) {
      if (position != null && mapboxMapController != null) {
        print('Current Position===> $position');
        _currentPosition = position;
        mapboxMapController?.setCamera(
          mb.CameraOptions(
            center: mb.Point(
              coordinates: mb.Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 15,
          ),
        );
      }
    });
  }

  void _goToMyLocation() async {
    if (_currentPosition != null && mapboxMapController != null) {
      mapboxMapController?.flyTo(
        mb.CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(
              _currentPosition!.longitude,
              _currentPosition!.latitude,
            ),
          ),
          zoom: 15,
          bearing: 45,
          pitch: 0,
        ),
        mb.MapAnimationOptions(duration: 1000),
      );
    } else {
      try {
        final position = await gl.Geolocator.getCurrentPosition();
        _currentPosition = position;
        mapboxMapController?.flyTo(
          mb.CameraOptions(
            center: mb.Point(
              coordinates: mb.Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 15,
            bearing: 45,
            pitch: 0,
          ),
          mb.MapAnimationOptions(duration: 1000),
        );
      } catch (e) {
        ToastService.show('Could not get current location');
      }
    }
  }

  void _rotateMapToShowCompass() {
    // Delay to ensure map is properly initialized
    Future.delayed(const Duration(seconds: 1), () {
      if (mapboxMapController != null) {
        mapboxMapController?.setCamera(
          mb.CameraOptions(
            bearing: 45.0,
          ),
        );
      }
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        onCategoryToggled: _updateCategoryMarkers,
      ),
    );
  }

  void _updateCategoryMarkers(String category) {
    switch (category) {
      case 'bronze':
        _updateBronzeMarkers();
        break;
      case 'silver':
        _updateSilverMarkers();
        break;
      case 'gold':
        _updateGoldMarkers();
        break;
    }
  }
}

