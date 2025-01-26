import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../MenuDisplayWeb.dart';
import '../MenuDisplayMobile.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 800;
  }

    String? tipoTela;
    if(isMobile(context)) {
      tipoTela = 'inicioMobile';
      print("Web\n");
    } else {
      tipoTela = 'inicioWeb';
      print("Mobile\n");
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: tipoTela,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('pt', 'BR')
      ],
       routes: {
        'inicioWeb' : (context) =>   const MenuDisplayWeb(), 
        'inicioMobile' : (context) =>   const MenuDisplayMobile(), 
       },
    );
  }
}



