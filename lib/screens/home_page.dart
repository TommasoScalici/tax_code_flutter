import 'package:flutter/material.dart';
import 'package:tax_code_flutter/widgets/home_view_phone.dart';
import 'package:tax_code_flutter/widgets/home_view_watch.dart';

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
