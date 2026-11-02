import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_fakes.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_shell.dart';

enum _ContactsListStateMode { populated, empty, demo, loading }

/// Interactive preview for [HomePage] and [ContactsList] on Wear OS.
class WearContactsListPreview extends StatefulWidget {
  @Preview(name: 'Wear Contacts List')
  const WearContactsListPreview({super.key});

  @override
  State<WearContactsListPreview> createState() =>
      _WearContactsListPreviewState();
}

class _WearContactsListPreviewState extends State<WearContactsListPreview> {
  late final FakeContactsListController _controller;
  _ContactsListStateMode _currentMode = _ContactsListStateMode.populated;

  @override
  void initState() {
    super.initState();
    _controller = FakeContactsListController(
      contacts: [
        TestContactFixtures.marioRossi,
        TestContactFixtures.lauraNeri,
        TestContactFixtures.giuseppeVerdi,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchMode(_ContactsListStateMode mode) {
    setState(() {
      _currentMode = mode;
      switch (mode) {
        case _ContactsListStateMode.populated:
          _controller.setLoading(loading: false);
          _controller.setDemoMode(demoMode: false);
          _controller.setContacts([
            TestContactFixtures.marioRossi,
            TestContactFixtures.lauraNeri,
            TestContactFixtures.giuseppeVerdi,
          ]);
        case _ContactsListStateMode.empty:
          _controller.setLoading(loading: false);
          _controller.setDemoMode(demoMode: false);
          _controller.setContacts([]);
        case _ContactsListStateMode.demo:
          _controller.setLoading(loading: false);
          _controller.setDemoMode(demoMode: true);
          _controller.setContacts([TestContactFixtures.marioRossi]);
        case _ContactsListStateMode.loading:
          _controller.setDemoMode(demoMode: false);
          _controller.setLoading(loading: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WearPreviewShell(
      providers: [
        ChangeNotifierProvider<ContactsListController>.value(
          value: _controller,
        ),
      ],
      routes: {
        '/barcode': (ctx) {
          final args =
              ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          final taxCode = args?['taxCode'] as String? ?? 'RSSMRA85D15H501Z';
          return BarcodePage(taxCode: taxCode);
        },
      },
      toolbarActions: (ctx, isRound) => [
        ChoiceChip(
          label: const Text('3 Contacts', style: TextStyle(fontSize: 12)),
          selected: _currentMode == _ContactsListStateMode.populated,
          onSelected: (_) => _switchMode(_ContactsListStateMode.populated),
        ),
        ChoiceChip(
          label: const Text('Empty', style: TextStyle(fontSize: 12)),
          selected: _currentMode == _ContactsListStateMode.empty,
          onSelected: (_) => _switchMode(_ContactsListStateMode.empty),
        ),
        ChoiceChip(
          label: const Text('Demo', style: TextStyle(fontSize: 12)),
          selected: _currentMode == _ContactsListStateMode.demo,
          onSelected: (_) => _switchMode(_ContactsListStateMode.demo),
        ),
        ChoiceChip(
          label: const Text('Loading', style: TextStyle(fontSize: 12)),
          selected: _currentMode == _ContactsListStateMode.loading,
          onSelected: (_) => _switchMode(_ContactsListStateMode.loading),
        ),
      ],
      child: const HomePage(),
    );
  }
}
