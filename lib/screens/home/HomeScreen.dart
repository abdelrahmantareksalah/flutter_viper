import 'package:flutter/material.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/utils/permission/getLocationPermission.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      child: Center(
        child: SizedBox(
          width: 500,
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 2,
            ),
            shrinkWrap: true,
            children: [
              navButton(
                context: context,
                text: 'Paths Map',
                route: "/map",
                icon: Icons.map,
              ),
              navButton(
                context: context,
                text: 'Create Path',
                route: "/map",
                icon: Icons.add_road_rounded,
              ),
              navButton(
                context: context,
                text: 'Navigate',
                route: "/command",
                icon: Icons.navigation_outlined,
              ),
              navButton(
                context: context,
                text: 'Command',
                route: "/command",
                icon: Icons.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navButton({
    required BuildContext context,
    required String text,
    required String route,
    IconData? icon,
  }) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      style: ButtonStyle(),
      icon: Icon(icon, size: 40),
      label: Text(text, textScaler: TextScaler.linear(1.5)),
    );
  }
}
