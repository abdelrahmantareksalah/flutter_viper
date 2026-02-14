import 'package:flutter/material.dart';

class LayoutComponent extends StatelessWidget {
  final Widget child;

  const LayoutComponent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("VIPER"),
      ),
      body: child
    );
  }
}
