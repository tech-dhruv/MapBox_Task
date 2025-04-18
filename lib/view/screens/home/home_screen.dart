import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/routes/app_routes.dart';
import 'package:mapbox_task/providers/auth_provider.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/view/screens/no_internet/no_internet.dart';

@RoutePage<String>()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  late ConnectivityProvider _connectivityProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _connectivityProvider = Provider.of<ConnectivityProvider>(context);
      _connectivityProvider.initConnectivity(mounted);
      _connectivityProvider.connectivitySubscription = _connectivityProvider
          .connectivity.onConnectivityChanged
          .listen(_connectivityProvider.updateConnectionStatus);
      // await _connectivityProvider.startMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, provider, child) {
        return (provider.connectionStatus == ConnectivityResult.mobile ||
                provider.connectionStatus == ConnectivityResult.wifi ||
                provider.connectionStatus == ConnectivityResult.ethernet ||
                provider.connectionStatus == ConnectivityResult.vpn)
            ? Scaffold(
                appBar: AppBar(
                  title: const Text("Home"),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: ColorPallet.primaryColor,
                      ),
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .test();
                      },
                      child: const Text("Test",
                          style: TextStyle(
                            color: ColorPallet.onPrimaryColor,
                          )),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: ColorPallet.primaryColor,
                      ),
                      onPressed: () {
                        AutoRouter.of(context).pushNamed(Routes.SECOND_SCREEN);
                      },
                      child: const Text("Navigate",
                          style: TextStyle(
                            color: ColorPallet.onPrimaryColor,
                          )),
                    ),
                  ],
                ),
              )
            : const NoInternetScreen();
      },
    );
  }
}
