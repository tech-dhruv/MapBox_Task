import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/utility/toast_service.dart';
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

  mb.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _setupPositionTracking();
      _connectivityProvider = Provider.of<ConnectivityProvider>(context);
      _connectivityProvider.initConnectivity(mounted);
      _connectivityProvider.connectivitySubscription = _connectivityProvider
          .connectivity.onConnectivityChanged
          .listen(_connectivityProvider.updateConnectionStatus);
    }
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
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
                  body: mb.MapWidget(
                    onMapCreated: _onMapCreated,
                    styleUri: mb.MapboxStyles.DARK,
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

    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
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
        print('Current Position===> $position');
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
}
