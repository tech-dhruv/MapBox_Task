import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_task/config/assets.dart';

@RoutePage()
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 25),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.NO_INTERNET),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "You are not connected to the internet. Make sure Wi-Fi is on, Airplane Mode is Off and try again.",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
