import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qtec_task/HomePage.dart';
import 'package:qtec_task/api_services/product_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Platform-safe Hive initialization
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }

  // Register Hive adapter
  Hive.registerAdapter(ProductHiveModelAdapter());

  // Open product cache box
  await Hive.openBox<ProductHiveModel>('products');

  // FlutterError handler for image loading / JSArray bugs
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final text = details.exceptionAsString();

    if (exception is NetworkImageLoadException ||
        text.contains('NetworkImageLoadException') ||
        (exception is TypeError && text.contains('JSArray<dynamic>')) ||
        text.contains('JDArray<dynamic>') ||
        (text.contains('is not a subtype of type \'Iterable') &&
            text.contains('JSArray<dynamic>'))) {
      return;
    }

    FlutterError.presentError(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Homepage());
  }
}
