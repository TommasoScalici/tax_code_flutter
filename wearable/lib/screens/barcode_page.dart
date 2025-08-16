import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/services/brightness_service.dart';

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
        title: Text(l10n.barcodePageTitle, style: const TextStyle(fontSize: 14)),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: BarcodeWidget(
            barcode: Barcode.code39(),
            backgroundColor: Colors.white,
            color: Colors.black,
            style: const TextStyle(color: Colors.black),
            data: widget.taxCode,
            height: 80,
          ),
        ),
      ),
    );
  }
}