import 'package:flutter/material.dart';
import 'package:shared/models/contact.dart';
import 'screens/auth_gate.dart';
import 'screens/barcode_page.dart';
import 'screens/camera_page.dart';
import 'screens/form_page.dart';
import 'screens/profile_screen.dart';

final class Routes {
  Routes._();

  static const String home = '/';
  static const String profile = '/profile';
  static const String form = '/form';
  static const String camera = '/camera';
  static const String barcode = '/barcode';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case form:
        final contact = settings.arguments as Contact?;
        return MaterialPageRoute(builder: (_) => FormPage(contact: contact));
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case barcode:
        final taxCode = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => BarcodePage(taxCode: taxCode));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
