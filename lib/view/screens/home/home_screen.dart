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
import 'package:mapbox_task/models/customer_model.dart';
import 'package:mapbox_task/models/stores_model.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/providers/map_provider.dart';
import 'package:mapbox_task/providers/search_provider.dart';
import 'package:mapbox_task/utility/marker_helper.dart';
import 'package:mapbox_task/utility/toast_service.dart';
import 'package:mapbox_task/view/base/theme_button.dart';
import 'package:mapbox_task/view/screens/home/filter_bottom_sheet.dart';
import 'package:mapbox_task/view/screens/home/search_screen.dart';
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
  late SearchProvider _searchProvider;
  
  mb.MapboxMap? mapboxMapController;
  mb.PointAnnotationManager? bronzeAnnotationManager;
  mb.PointAnnotationManager? silverAnnotationManager;
  mb.PointAnnotationManager? goldAnnotationManager;
  mb.PointAnnotationManager? customerAnnotationManager;
  mb.PointAnnotationManager? searchResultAnnotationManager;
  
  StreamSubscription? userPositionStream;
  gl.Position? _currentPosition;
  bool _storesLoaded = false;
  bool _customersLoaded = false;
  
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
      _searchProvider = Provider.of<SearchProvider>(context);
      _connectivityProvider.initConnectivity(mounted);
      _connectivityProvider.connectivitySubscription = _connectivityProvider
          .connectivity.onConnectivityChanged
          .listen(_connectivityProvider.updateConnectionStatus);
      
      _preloadMarkerAssets();
      _listenForSearchSelection();
    }
  }

  @override
  void initState() {
    super.initState();
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
  
  void _listenForSearchSelection() {
    _searchProvider.addListener(() {
      final selectedPlace = _searchProvider.selectedPlace;
      if (selectedPlace != null) {
        if (mapboxMapController != null) {
          Future.delayed(Duration.zero, () {
            _navigateToSelectedPlace(selectedPlace);
          });
        }
      }
    });
  }
  
  void _navigateToSelectedPlace(place) {
    if (mapboxMapController != null) {
      mapboxMapController!.flyTo(
        _searchProvider.getCameraOptionsForPlace(place),
        mb.MapAnimationOptions(duration: 1000),
      );
      
      _addSelectedPlaceMarker(place);
    }
  }
  
  Future<void> _addSelectedPlaceMarker(place) async {
    try {
      if (mapboxMapController == null) return;
      
      if (searchResultAnnotationManager != null) {
        try {
          await searchResultAnnotationManager!.deleteAll();
        } catch (e) {
          searchResultAnnotationManager = null;
        }
      }
      
      if (searchResultAnnotationManager == null) {
        try {
          searchResultAnnotationManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        } catch (e) {
          return;
        }
      }
      
      Uint8List? markerImageBytes = _markerImageCache[Assets.BLUE_CUSTOMER_PIN];
      if (markerImageBytes == null) {
        try {
          final ByteData data = await rootBundle.load(Assets.BLUE_CUSTOMER_PIN);
          markerImageBytes = data.buffer.asUint8List();
          _markerImageCache[Assets.BLUE_CUSTOMER_PIN] = markerImageBytes;
        } catch (e) {
          return;
        }
      }
      
      final markerOptions = mb.PointAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(
            place.longitude,
            place.latitude,
          ),
        ),
        image: markerImageBytes,
        iconSize: 0.2,
      );
      
      try {
        await searchResultAnnotationManager!.create(markerOptions);
      } catch (e) {}
    } catch (e) {}
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
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => Container(
                                            height: MediaQuery.of(context).size.height * 0.9,
                                            decoration: const BoxDecoration(
                                              color: ColorPallet.darkBlackColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: const SearchScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: ColorPallet.secondaryDarkBlackColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: ColorPallet.whiteColor),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.search,
                                              color: ColorPallet.whiteColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Consumer<SearchProvider>(
                                                builder: (context, searchProvider, _) {
                                                  final selectedPlace = searchProvider.selectedPlace;
                                                  return Text(
                                                    selectedPlace != null
                                                        ? selectedPlace.name
                                                        : 'Search for a place',
                                                    style: TextStyles.bodyText2(
                                                      color: selectedPlace != null
                                                          ? ColorPallet.whiteColor.withOpacity(0.8)
                                                          : ColorPallet.whiteColor.withOpacity(0.6),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                },
                                              ),
                                            ),
                                            Consumer<SearchProvider>(
                                              builder: (context, searchProvider, _) {
                                                if (searchProvider.selectedPlace != null) {
                                                  return IconButton(
                                                    icon: const Icon(
                                                      Icons.clear,
                                                      color: ColorPallet.whiteColor,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      searchProvider.clearSelectedPlace();
                                                      searchProvider.clearSearch();
                                                    },
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Consumer<MapProvider>(
                                    builder: (context, mapProvider, _) {
                                      int activeFilters = 0;
                                      if (mapProvider.showBronzeStores) activeFilters++;
                                      if (mapProvider.showSilverStores) activeFilters++;
                                      if (mapProvider.showGoldStores) activeFilters++;
                                      if (mapProvider.showCustomers) activeFilters++;
                                      
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
                                          if (activeFilters > 0 && activeFilters < 4)
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: ColorPallet.secondaryColor,
                                                  border: Border.all(color: ColorPallet.whiteColor),
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
                          ],
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
      
      await mapboxMapController?.location.updateSettings(
        mb.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );
      
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
      
      await mapboxMapController?.scaleBar.updateSettings(
        mb.ScaleBarSettings(
          enabled: true,
          position: mb.OrnamentPosition.TOP_LEFT,
          marginTop: 70.0,
          marginLeft: 16.0,
        ),
      );
      
      await Future.delayed(const Duration(seconds: 1));
      
      await _initializeAnnotationManagers();
      
      _preloadMarkerAssets().then((_) {
        _loadStoresAndCreateMarkers();
        _loadCustomersAndCreateMarkers();
      });
    } catch (e) {
      ToastService.show('Error initializing map');
    }
  }

  Future<void> _initializeAnnotationManagers() async {
    try {
      if (mapboxMapController != null) {
        print('Initializing annotation managers');
        
        
        final bronzeManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        final silverManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        final goldManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        final customerManager = await mapboxMapController!.annotations.createPointAnnotationManager();
        
        setState(() {
          bronzeAnnotationManager = bronzeManager;
          silverAnnotationManager = silverManager;
          goldAnnotationManager = goldManager;
          customerAnnotationManager = customerManager;
        });
        
        _mapProvider.bronzeAnnotationManager = bronzeManager;
        _mapProvider.silverAnnotationManager = silverManager;
        _mapProvider.goldAnnotationManager = goldManager;
        _mapProvider.customerAnnotationManager = customerManager;
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

  Future<void> _loadCustomersAndCreateMarkers() async {
    if (_customersLoaded) return;
    
    try {
      await _mapProvider.fetchCustomers();
      
      if (_mapProvider.customers.isNotEmpty) {
        await _createCustomerMarkers();
        
        setState(() {
          _customersLoaded = true;
        });
      }
    } catch (e) {
      ToastService.show('Failed to load customer markers');
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
        Assets.BLUE_CUSTOMER_PIN,
      ];
      
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

  Future<void> _createCustomerMarkers() async {
    if (customerAnnotationManager == null || _mapProvider.customers.isEmpty) return;
    
    try {
      await _createMarkersForCustomers(_mapProvider.customers, customerAnnotationManager!);
      print('Created ${_mapProvider.customers.length} customer markers');
    } catch (e) {
      print('Error creating customer markers: $e');
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
      if (!_assetsPreloaded) {
        await _preloadMarkerAssets();
      }
      
      final storesToDisplay = stores.take(50).toList();
      
      const int batchSize = 10;
      for (int i = 0; i < storesToDisplay.length; i += batchSize) {
        final int end = (i + batchSize < storesToDisplay.length) 
            ? i + batchSize 
            : storesToDisplay.length;
            
        final List<mb.PointAnnotationOptions> markerBatch = [];
        
        for (int j = i; j < end; j++) {
          final store = storesToDisplay[j];
          
          if (store.geoLocation?.latitude == null || 
              store.geoLocation?.longitude == null ||
              store.id == null) {
            continue;
          }
          
          try {
            final markerAsset = MarkerHelper.getMarkerAsset(store);
            
            Uint8List? markerImageBytes = _markerImageCache[markerAsset];
            if (markerImageBytes == null) {
              final ByteData bytes = await rootBundle.load(markerAsset);
              markerImageBytes = bytes.buffer.asUint8List();
              _markerImageCache[markerAsset] = markerImageBytes;
            }
            
            final markerOption = mb.PointAnnotationOptions(
              geometry: mb.Point(
                coordinates: mb.Position(
                  store.geoLocation!.longitude!,
                  store.geoLocation!.latitude!,
                ),
              ),
              image: markerImageBytes,
              iconSize: 0.15,
            );
            
            markerBatch.add(markerOption);
          } catch (e) {
            print('Error creating marker for store ${store.id}: $e');
          }
        }
        
        if (markerBatch.isNotEmpty) {
          try {
            await manager.createMulti(markerBatch);
          } catch (e) {
            print('Error adding marker batch: $e');
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error in _createMarkersForStores: $e');
    }
  }

  Future<void> _createMarkersForCustomers(List<Customer> customers, mb.PointAnnotationManager manager) async {
    try {
      if (!_assetsPreloaded) {
        await _preloadMarkerAssets();
      }
      
      const int batchSize = 10;
      for (int i = 0; i < customers.length; i += batchSize) {
        final int end = (i + batchSize < customers.length) 
            ? i + batchSize 
            : customers.length;
            
        final List<mb.PointAnnotationOptions> markerBatch = [];
        
        for (int j = i; j < end; j++) {
          final customer = customers[j];
          
          if (customer.geoLocation?.latitude == null || 
              customer.geoLocation?.longitude == null ||
              customer.customerId == null) {
            continue;
          }
          
          try {
            final markerAsset = Assets.BLUE_CUSTOMER_PIN;
            
            Uint8List? markerImageBytes = _markerImageCache[markerAsset];
            if (markerImageBytes == null) {
              final ByteData bytes = await rootBundle.load(markerAsset);
              markerImageBytes = bytes.buffer.asUint8List();
              _markerImageCache[markerAsset] = markerImageBytes;
            }
            
            final markerOption = mb.PointAnnotationOptions(
              geometry: mb.Point(
                coordinates: mb.Position(
                  customer.geoLocation!.longitude!,
                  customer.geoLocation!.latitude!,
                ),
              ),
              image: markerImageBytes,
              iconSize: 0.15,
            );
            
            markerBatch.add(markerOption);
          } catch (e) {
            print('Error creating marker for customer ${customer.customerId}: $e');
          }
        }
        
        if (markerBatch.isNotEmpty) {
          try {
            await manager.createMulti(markerBatch);
          } catch (e) {
            print('Error adding customer marker batch: $e');
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error in _createMarkersForCustomers: $e');
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

  void _updateCustomerMarkers() async {
    try {
      if (customerAnnotationManager != null) {
        await customerAnnotationManager!.deleteAll();
        
        if (_mapProvider.showCustomers) {
          await _createCustomerMarkers();
        }
      }
    } catch (e) {
      print('Error updating customer markers: $e');
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
      case 'customers':
        _updateCustomerMarkers();
        break;
    }
  }
}

