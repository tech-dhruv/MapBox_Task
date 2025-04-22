import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/config/text_style.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/providers/map_provider.dart';
import 'package:mapbox_task/utility/toast_service.dart';
import 'package:mapbox_task/view/base/theme_button.dart';
import 'package:mapbox_task/view/base/theme_input_field.dart';
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
  StreamSubscription? userPositionStream;
  gl.Position? _currentPosition;
  final GlobalKey _filterKey = GlobalKey();
  
  // Timer to periodically check the zoom level
  Timer? _zoomCheckTimer;
  double _currentZoom = 10.0;

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
    _zoomCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityProvider, MapProvider>(
      builder: (consumerContext, connectivityProvider, mapProvider, child) {
        return (connectivityProvider.connectionStatus == ConnectivityResult.mobile ||
                connectivityProvider.connectionStatus == ConnectivityResult.wifi ||
                connectivityProvider.connectionStatus == ConnectivityResult.ethernet ||
                connectivityProvider.connectionStatus == ConnectivityResult.vpn)
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
                              CCIconButton(
                                key: _filterKey,
                                buttonHeight: 50,
                                buttonWidth: 50,
                                shadow: false,
                                onTap: _showFilterMenu,
                                icon: Icon(Icons.filter_alt_outlined, color: ColorPallet.whiteColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (mapProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: ColorPallet.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  floatingActionButton: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'my_location',
                        shape: const CircleBorder(),
                        onPressed: _goToMyLocation,
                        backgroundColor: ColorPallet.secondaryColor.withOpacity(0.8),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const NoInternetScreen();
      },
    );
  }

  void _onMapCreated(mb.MapboxMap controller) {
    setState(() {
      mapboxMapController = controller;
    });
    
    // Set the controller in the map provider
    Provider.of<MapProvider>(context, listen: false).setMapboxMap(controller);

    // Set up location component
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Configure compass settings
    mapboxMapController?.compass.updateSettings(
      mb.CompassSettings(
        enabled: true,
        position: mb.OrnamentPosition.TOP_RIGHT,
        marginTop: 70.0,
        marginRight: 16.0,
        fadeWhenFacingNorth: false,
        opacity: 1.0,
      ),
    );

    // Configure scale bar (distance ruler) settings
    mapboxMapController?.scaleBar.updateSettings(
      mb.ScaleBarSettings(
        enabled: true,
        position: mb.OrnamentPosition.TOP_LEFT,
        marginTop: 70.0,
        marginLeft: 16.0,
      ),
    );
    
    // Get initial zoom level
    mapboxMapController?.getCameraState().then((state) {
      _currentZoom = state.zoom;
    });
    
    // Start periodic zoom check
    _startZoomCheck();
    
    // Load stores data from JSON
    _loadStoresData();
  }

  // Periodically check zoom level to update markers when needed
  void _startZoomCheck() {
    _zoomCheckTimer?.cancel();
    _zoomCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mapboxMapController != null) {
        mapboxMapController!.getCameraState().then((state) {
          final newZoom = state.zoom;
          
          // Check if we crossed the threshold for clustering
          if ((_currentZoom < 10 && newZoom >= 10) || (_currentZoom >= 10 && newZoom < 10)) {
            _currentZoom = newZoom;
            Provider.of<MapProvider>(context, listen: false).loadMarkers();
          } else {
            _currentZoom = newZoom;
          }
        });
      }
    });
  }
  
  Future<void> _loadStoresData() async {
    await Provider.of<MapProvider>(context, listen: false).fetchStores();
  }
  
  void _showFilterMenu() {
    final RenderBox renderBox = _filterKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: [
        _buildFilterMenuItem('Bronze Stores', Consumer<MapProvider>(
          builder: (context, mapProvider, _) => Checkbox(
            value: mapProvider.showBronzeStores,
            onChanged: (_) => mapProvider.toggleBronzeStores(),
          ),
        )),
        _buildFilterMenuItem('Silver Stores', Consumer<MapProvider>(
          builder: (context, mapProvider, _) => Checkbox(
            value: mapProvider.showSilverStores,
            onChanged: (_) => mapProvider.toggleSilverStores(),
          ),
        )),
        _buildFilterMenuItem('Gold Stores', Consumer<MapProvider>(
          builder: (context, mapProvider, _) => Checkbox(
            value: mapProvider.showGoldStores,
            onChanged: (_) => mapProvider.toggleGoldStores(),
          ),
        )),
      ],
      elevation: 8.0,
      color: ColorPallet.secondaryDarkBlackColor,
    );
  }
  
  PopupMenuItem<String> _buildFilterMenuItem(String title, Widget trailing) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyles.bodyText2(color: ColorPallet.whiteColor)),
          trailing,
        ],
      ),
    );
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
          bearing: 0,
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
            bearing: 0,
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
}
