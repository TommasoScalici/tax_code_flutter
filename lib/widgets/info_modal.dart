import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoModal extends StatelessWidget {
  const InfoModal({super.key});

  Future<String> getHtmlPrivacyPolicy(BuildContext context) async {
    var languageCode = Localizations.localeOf(context).languageCode;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('html-strings')
        .where('name', isEqualTo: 'privacy_policy')
        .get();

    var doc = querySnapshot.docs.firstOrNull;

    if (doc != null) {
      return doc.data()[languageCode] as String;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getHtmlPrivacyPolicy(context),
        builder: (context, snapshot) {
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
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  snapshot.hasData
                      ? SizedBox(
                          height: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: HtmlWidget(
                                snapshot.data!,
                                onTapUrl: (url) async =>
                                    await launchUrl(Uri.parse(url)),
                              ),
                            ),
                          ),
                        )
                      : snapshot.hasError
                          ? Text(
                              AppLocalizations.of(context)!.errorNoInternet,
                              textAlign: TextAlign.center,
                            )
                          : const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
