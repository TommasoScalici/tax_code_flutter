import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_shell.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contact_card.dart';

/// Interactive preview for [WearContactCard] on Wear OS displays.
class WearContactCardPreview extends StatefulWidget {
  @Preview(name: 'Wear Contact Card')
  const WearContactCardPreview({super.key});

  @override
  State<WearContactCardPreview> createState() => _WearContactCardPreviewState();
}

class _WearContactCardPreviewState extends State<WearContactCardPreview> {
  int _selectedContactIndex = 0;
  int _tapCount = 0;

  final List<Contact> _sampleContacts = [
    TestContactFixtures.marioRossi,
    TestContactFixtures.lauraNeri,
    TestContactFixtures.giuseppeVerdi,
  ];

  @override
  Widget build(BuildContext context) {
    final contact = _sampleContacts[_selectedContactIndex];

    return WearPreviewShell(
      toolbarActions: (ctx, isRound) => [
        ActionChip(
          avatar: const Icon(Icons.person_outline_rounded, size: 16),
          label: Text(contact.firstName, style: const TextStyle(fontSize: 12)),
          onPressed: () {
            setState(() {
              _selectedContactIndex =
                  (_selectedContactIndex + 1) % _sampleContacts.length;
            });
          },
        ),
        if (_tapCount > 0)
          Chip(
            label: Text(
              'Tapped: $_tapCount',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.emeraldLight,
              ),
            ),
            backgroundColor: const Color(0xFF0F172A),
          ),
      ],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WearDimensions.screenPaddingHorizontal,
          ),
          child: WearContactCard(
            contact: contact,
            onTap: () {
              setState(() {
                _tapCount++;
              });
            },
          ),
        ),
      ),
    );
  }
}
