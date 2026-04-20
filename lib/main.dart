import 'package:flutter/material.dart';
import 'core/services/service_locator.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/sus_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(const FluxSUSApp());
}

class FluxSUSApp extends StatelessWidget {
  const FluxSUSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluxSUS',
      theme: SUSTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
