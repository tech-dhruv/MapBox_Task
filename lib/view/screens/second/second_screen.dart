import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_task/config/color.dart';
import 'package:mapbox_task/providers/auth_provider.dart';

import '../../../routes/app_routes.dart';

@RoutePage()
class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second"),
      ),
      body: Center(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: ColorPallet.primaryColor,
          ),
          onPressed: () {
            AutoRouter.of(context).pushNamed(Routes.HOME);
          },
          child: const Text("Back",
              style: TextStyle(
                color: ColorPallet.onPrimaryColor,
              )),
        ),
      ),
    );
  }
}
