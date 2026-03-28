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

  static Route<Object?> generateRoute(RouteSettings settings) {
    var routeName = settings.name;

    if (routeName != null) {
      final uri = Uri.tryParse(routeName);
      if (uri != null && uri.scheme == 'app') {
        routeName = uri.path.isEmpty ? home : uri.path;
      }
    }

    switch (routeName) {
      case home:
        return MaterialPageRoute<void>(builder: (_) => const AuthGate());
      case profile:
        return MaterialPageRoute<void>(builder: (_) => const ProfileScreen());
      case form:
        final contact = settings.arguments as Contact?;
        return MaterialPageRoute<Contact?>(
          builder: (_) => FormPage(contact: contact),
        );
      case camera:
        return MaterialPageRoute<void>(builder: (_) => const CameraPage());
      case barcode:
        final taxCode = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => BarcodePage(taxCode: taxCode),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
