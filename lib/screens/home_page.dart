import 'package:flutter/material.dart';

import '../wear_os/screens/home_view_watch.dart';
import '../widgets/home_view_phone.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 300) {
        return HomeViewWatch();
      } else {
        return HomeViewPhone();
      }
    });
  }
}
