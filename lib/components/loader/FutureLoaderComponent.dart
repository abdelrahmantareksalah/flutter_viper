import 'package:flutter/material.dart';

class FutureLoaderComponent<T> extends StatefulWidget {
  final T? initialData;
  final Future<T?>? future;
  final Widget Function(BuildContext, T?) builder;
  final Widget Function(BuildContext)? loading;
  final Widget Function(BuildContext, Object?)? error;
  final Widget Function(BuildContext)? none;

  const FutureLoaderComponent({
    super.key,
    this.initialData,
    required this.future,
    required this.builder,
    this.loading,
    this.error,
    this.none,
  });

  @override
  State<FutureLoaderComponent<T>> createState() =>
      _FutureLoaderComponentState<T>();
}

class _FutureLoaderComponentState<T> extends State<FutureLoaderComponent<T>> {
  T? _dataFuture;

  @override
  Widget build(BuildContext context) {
    return _dataFuture != null
        ? widget.builder(context, _dataFuture)
        : FutureBuilder<T?>(
            initialData: widget.initialData,
            future: widget.future,
            builder: (BuildContext context, AsyncSnapshot<T?> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return widget.loading?.call(context) ??
                      const Center(child: CircularProgressIndicator());

                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return widget.error?.call(context, snapshot.error) ??
                        Center(child: Text("Error: ${snapshot.error}"));
                  }
                  _dataFuture = snapshot.data;
                  // Even if data is null, the future is "done"
                  return widget.builder(context, snapshot.data);

                default:
                  return widget.none?.call(context) ??
                      const Center(child: Text("No connection started."));
              }
            },
          );
  }
}
