import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

class ErrorDialogHelper {
  static void showErrorDialog(BuildContext context, String errorKey) {
    final l10n = AppLocalizations.of(context)!;
    String message;

    switch (errorKey) {
      case 'deadlineExceeded':
        message = l10n.deadlineExceeded;
        break;
      case 'rateLimitExceeded':
        message = l10n.rateLimitExceeded;
        break;
      case 'serviceUnavailable':
        message = l10n.serviceUnavailable;
        break;
      case 'networkError':
        message = l10n.networkError;
        break;
      case 'sessionExpired':
        message = l10n.sessionExpired;
        break;
      case 'genericError':
      default:
        message = l10n.genericError;
        break;
    }

    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.error),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          );
        },
      ),
    );
  }
}
