import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoModal extends StatelessWidget {
  const InfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final infoService = context.read<InfoServiceAbstract>();
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.appTitle,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                child: FutureBuilder<List<Object>>(
                  future: Future.wait([
                    infoService.getLocalizedTerms(locale),
                    infoService.getPackageInfo(),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 2) {
                      return Center(child: Text(l10n.genericError));
                    }

                    final termsHtml = snapshot.data![0] as String;
                    final packageInfo = snapshot.data![1] as PackageInfo;

                    return Column(
                      children: [
                        HtmlWidget(
                          termsHtml,
                          onTapUrl: (url) => launchUrl(Uri.parse(url)),
                        ),
                        const SizedBox(height: 20),
                        _PackageInfoView(
                          packageInfo: packageInfo,
                          l10n: l10n,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageInfoView extends StatelessWidget {
  final PackageInfo packageInfo;
  final AppLocalizations l10n;
  const _PackageInfoView({required this.packageInfo, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: l10n.appName, value: packageInfo.appName),
        _InfoRow(label: l10n.packageName, value: packageInfo.packageName),
        _InfoRow(label: l10n.appVersion, value: packageInfo.version),
        _InfoRow(label: l10n.buildNumber, value: packageInfo.buildNumber),
        _InfoRow(label: l10n.buildSignature, value: packageInfo.buildSignature),
        _InfoRow(label: l10n.installerStore, value: packageInfo.installerStore ?? 'N/A'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}