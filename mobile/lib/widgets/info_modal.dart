import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<String> _getHtmlTerms(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final htmlPath = _getLocalizedHtmlTermsPath(locale);
    final htmlContent = await rootBundle.loadString(htmlPath);
    return htmlContent;
  }

  String _getLocalizedHtmlTermsPath(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'assets/html/it/terms.html';
      case 'en':
        return 'assets/html/en/terms.html';
      default:
        return 'assets/html/en/terms.html';
    }
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
        future: _getHtmlTerms(context),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? HtmlWidget(
                  snapshot.data!,
                  onTapUrl: (url) async => await launchUrl(Uri.parse(url)),
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
