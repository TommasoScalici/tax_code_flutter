import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wear/wear.dart';

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
    Future.microtask(() async {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    ScreenBrightness().resetApplicationScreenBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 300) {
        return WatchShape(
          builder: (BuildContext context, WearShape shape, Widget? child) {
            final isRound = shape == WearShape.round;
            final padding = isRound ? 20.0 : 10.0;

            return Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code39(),
                    backgroundColor: Colors.white,
                    drawText: false,
                    data: widget.taxCode,
                    height: isRound ? 80 : 100,
                    width: MediaQuery.of(context).size.width * .8,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)!.appTitle),
          ),
          body: Center(
            child: BarcodeWidget(
              barcode: Barcode.code39(),
              data: widget.taxCode,
              height: 150,
              width: MediaQuery.of(context).size.width * .8,
            ),
          ),
        );
      }
    });
  }
}
