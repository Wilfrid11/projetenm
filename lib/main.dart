import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'coeur/notifications/fcm_service.dart';
import 'coeur/theme/theme_mode_controller.dart';
import 'modules/auth/presentation/login.dart';
import '../modules/produits/logique/stock_controller.dart'; // Import du contrôleur de stock global

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmService.instance.initialiser();
  runApp(const MyApp());
}
final StockController _mainStockController = StockController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'QuincaPro',
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: Login(stockController: _mainStockController),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

