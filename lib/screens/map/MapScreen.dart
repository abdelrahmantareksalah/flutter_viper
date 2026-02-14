import 'package:flutter/material.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      child: Center(
        child: MapComponent()
      ),
    );
  }

  
}
