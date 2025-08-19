import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BarcodeWidget(
            barcode: Barcode.code39(),
            data: widget.taxCode,
            width: double.infinity,
            height: 80,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Roboto',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
