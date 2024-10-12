import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoModal extends StatefulWidget {
  const InfoModal({super.key});

  @override
  State<InfoModal> createState() => _InfoModalState();
}

class _InfoModalState extends State<InfoModal> {
  var _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<String> _getHtmlPrivacyPolicy(BuildContext context) async {
    var languageCode = Localizations.localeOf(context).languageCode;

    if (Platform.isAndroid) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('html-strings')
          .where('name', isEqualTo: 'privacy_policy')
          .get();

      var doc = querySnapshot.docs.firstOrNull;

      if (doc != null) {
        return doc.data()[languageCode] as String;
      }
    }

    return '';
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  Widget _getInfoPackageTexts() {
    return Column(children: [
      Text('${AppLocalizations.of(context)?.appName}:'),
      Text(
        _packageInfo.appName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
      Text('${AppLocalizations.of(context)?.packageName}:'),
      Text(
        _packageInfo.packageName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
      Text('${AppLocalizations.of(context)?.appVersion}:'),
      Text(
        _packageInfo.version,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
      Text('${AppLocalizations.of(context)?.buildNumber}:'),
      Text(
        _packageInfo.buildNumber,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
      Text('${AppLocalizations.of(context)?.buildSignature}:'),
      Text(
        _packageInfo.buildSignature,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
      Text('${AppLocalizations.of(context)?.installerStore}:'),
      Text(
        _packageInfo.installerStore != null
            ? _packageInfo.installerStore!
            : 'Unknown',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(''),
    ]);
  }

  FutureBuilder<String> _getModalContent() {
    return FutureBuilder<String>(
        future: _getHtmlPrivacyPolicy(context),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? HtmlWidget(
                  snapshot.data!,
                  onTapUrl: (url) async => await launchUrl(Uri.parse(url)),
                )
              : snapshot.hasError
                  ? Text(
                      AppLocalizations.of(context)!.errorNoInternet,
                      textAlign: TextAlign.center,
                    )
                  : const CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.appTitle,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  _getModalContent(),
                  SizedBox(height: 20),
                  _getInfoPackageTexts(),
                ],
              )),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    var currentFocusNode = FocusManager.instance.primaryFocus;
                    if (currentFocusNode != null) {
                      currentFocusNode.unfocus();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
