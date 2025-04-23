import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/painting.dart'; // for NetworkImageLoadException
import 'package:qtec_task/HomePage.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final text = details.exceptionAsString();

    // 1) genuine broken-image load   → swallow
    // 2) DDC JSArray TypeError bug  → swallow
    if (exception is NetworkImageLoadException ||
        text.contains('NetworkImageLoadException') ||
        // DDC bug: JSArray<dynamic> treated as wrong listener type
        (exception is TypeError && text.contains('JSArray<dynamic>')) ||
        text.contains('JDArray<dynamic>') ||
        text.contains('is not a subtype of type \'Iterable') &&
            text.contains('JSArray<dynamic>')) {
      // ignore these
      return;
    }

    // otherwise, fall back to default:
    FlutterError.presentError(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
    );
  }
}
