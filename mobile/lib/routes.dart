import 'package:material_ui/material_ui.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/scanned_data.dart';
import 'screens/auth_gate.dart';
import 'screens/camera_page.dart';
import 'screens/form_page.dart';
import 'screens/welcome_screen.dart';

final class Routes {
  Routes._();

  static const String home = '/';
  static const String camera = '/camera';
  static const String form = '/form';
  static const String welcome = '/welcome';

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
      case welcome:
        return MaterialPageRoute<void>(builder: (_) => const WelcomeScreen());
      case form:
        final contact = settings.arguments as Contact?;
        return MaterialPageRoute<Contact?>(
          builder: (_) => FormPage(contact: contact),
        );
      case camera:
        return MaterialPageRoute<ScannedData?>(
          builder: (_) => const CameraPage(),
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
