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
    super.initState();
    getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      // We add a Column because Expanded needs a Flex parent (Column or Row)
      child: Padding(
        padding: const EdgeInsets.all(20.0),

          child: Column(
            children: [
              // Expanded stretches the Center/SizedBox to fill the screen height
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GridView(
                      // physics stops the "scrolling" feel

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // You chose 1 column
                        mainAxisSpacing: 20.0,
                        crossAxisSpacing: 10.0,
                        // If you want them to fill the height more, make this 1.2 or 1.0
                        childAspectRatio: 3, 
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
                          route: "/createPath",
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
              ),
            ],
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
      // styleFrom makes it easier to change button appearance
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      icon: Icon(icon, size: 50), // Bigger icons for tablet
      label: Text(text, style: const TextStyle(fontSize: 24)),
    );
  }
}