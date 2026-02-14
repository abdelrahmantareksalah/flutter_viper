import 'package:flutter/material.dart';

class LayoutComponent extends StatelessWidget {
  final Widget child;
  final String? subTitle;
  final List<Widget>? actions;

  const LayoutComponent({
    super.key,
    required this.child,
    this.subTitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("VIPER" + (subTitle != null ? " - " + subTitle! : "")),
        actions: actions,
      ),
      body: child,
    );
  }
}
