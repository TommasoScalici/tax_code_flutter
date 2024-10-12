import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key, required this.taxCode});

  final String taxCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(
        child: BarcodeWidget(
          barcode: Barcode.code39(),
          data: taxCode,
          height: 150,
          width: MediaQuery.of(context).size.width * .8,
        ),
      ),
    );
  }
}
