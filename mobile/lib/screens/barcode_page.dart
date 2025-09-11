import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key, required this.taxCode});

  final String taxCode;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  late final BrightnessServiceAbstract _brightnessService;

  @override
  void initState() {
    super.initState();
    _brightnessService = context.read<BrightnessServiceAbstract>();
    _brightnessService.setMaxBrightness();
  }

  @override
  void dispose() {
    _brightnessService.resetBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.barcodePageTitle),
      ),
      body: SafeArea(
        child: Center(
          child: BarcodeWidget(
            barcode: Barcode.code39(),
            style: const TextStyle(color: Colors.black),
            data: widget.taxCode,
            height: 150,
            width: MediaQuery.of(context).size.width * .8,
          ),
        ),
      ),
    );
  }
}
