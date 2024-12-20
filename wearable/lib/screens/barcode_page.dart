import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key, required this.taxCode});

  final String taxCode;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  @override
  void initState() {
    super.initState();
    ScreenBrightness().setApplicationScreenBrightness(1.0);
  }

  @override
  void dispose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
