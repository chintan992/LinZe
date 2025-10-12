import 'package:flutter/material.dart';
import 'package:linze/features/welcome/welcome_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
      };
}
