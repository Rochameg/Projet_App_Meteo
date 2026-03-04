import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/meteo_provider.dart';
//import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'screens/bienvenue_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AppMeteo());
}

class AppMeteo extends StatelessWidget {
  const AppMeteo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeteoFournisseur(),
      child: Consumer<MeteoFournisseur>(
        builder: (context, fournisseur, _) {
          return MaterialApp(
            title: 'Météo Mondiale',
            debugShowCheckedModeBanner: false,
            themeMode:
                fournisseur.estModeSombre ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const EcranAccueil(),
          );
        },
      ),
    );
  }
}
