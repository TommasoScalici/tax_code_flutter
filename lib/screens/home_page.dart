import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../wear_os/screens/home_view_watch.dart';
import '../widgets/home_view_phone.dart';

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();
    appState.loadContacts();
    appState.loadTheme();
  }

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
